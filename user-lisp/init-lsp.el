;;; init-lsp.el --- Tree-sitter, Eglot, diagnostics and formatting -*- lexical-binding: t -*-

;;; Commentary:
;; Tree-sitter modes for all supported languages, grammars installed on
;; first use.  Eglot starts the Homebrew language servers that Eglot
;; already knows about, and for Python basedpyright and ruff together
;; through rass.  JSON files are checked against the SchemaStore
;; schemas.  Flymake shows the diagnostics, and next to them the same
;; linters as nvim-lint.  C-c c f runs the same formatters as
;; conform.nvim.

;;; Code:

;; Use the *-ts-mode of every language that has one.  When a grammar
;; is missing, Emacs offers to build it (needs Xcode Command Line Tools).
(setopt treesit-enabled-modes t)

;; Emacs 31 ships markdown-ts-mode as experimental and does not autoload
;; it or associate it with .md files.
(autoload 'markdown-ts-mode "markdown-ts-mode" nil t)
(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-ts-mode))

(defvar my-json-schemas-file (locate-user-emacs-file "schemastore.json")
  "Local copy of the SchemaStore catalog.")

(defvar my-json-schemas nil
  "Schema associations read from `my-json-schemas-file', once per session.")

(defun my-json-schemas-update ()
  "Download the SchemaStore catalog to `my-json-schemas-file'.
The old copy is kept unless the new one downloads and parses."
  (interactive)
  (let ((temp (make-temp-file "schemastore" nil ".json")))
    (unwind-protect
        (progn
          (url-copy-file "https://www.schemastore.org/api/json/catalog.json" temp t)
          (with-temp-buffer
            (insert-file-contents temp)
            (json-parse-buffer))        ; signals unless it is JSON
          (rename-file temp my-json-schemas-file t)
          (setq my-json-schemas nil)
          (message "SchemaStore catalog updated"))
      (when (file-exists-p temp)
        (delete-file temp)))))

(defun my-json-schemas ()
  "Return the SchemaStore schemas as vscode-json-languageserver settings.
Without the catalog, return no schemas, so only files with a $schema
key are validated.  Reading it takes a few milliseconds."
  (or my-json-schemas
      (setq my-json-schemas
            (or (with-demoted-errors "SchemaStore catalog unreadable: %S"
                  (when (file-exists-p my-json-schemas-file)
                    (with-temp-buffer
                      (insert-file-contents my-json-schemas-file)
                      (vconcat
                       (seq-keep (lambda (schema)
                                   (when-let* ((files (plist-get schema :fileMatch)))
                                     (list :fileMatch files :url (plist-get schema :url))))
                                 (plist-get (json-parse-buffer :object-type 'plist)
                                            :schemas))))))
                []))))

(defun my-json-schemas-ensure ()
  "Download the SchemaStore catalog if it is missing.
Runs when a JSON file opens, before Eglot starts its server."
  (unless (file-exists-p my-json-schemas-file)
    (with-demoted-errors "SchemaStore catalog download failed: %S"
      (my-json-schemas-update))))

(add-hook 'json-ts-mode-hook #'my-json-schemas-ensure)

(declare-function eglot-alternatives "eglot")

(defun my-eglot-workspace-configuration (_server)
  "Return the settings that Eglot sends to every language server.
basedpyright leaves organizing imports to ruff, as in the Neovim setup."
  `(:basedpyright (:disableOrganizeImports t
                   :analysis (:typeCheckingMode "standard"))
    :json (:schemas ,(my-json-schemas) :validate (:enable t))))

(use-package eglot
  :hook ((bash-ts-mode
          json-ts-mode
          lua-ts-mode
          markdown-ts-mode
          python-ts-mode
          toml-ts-mode
          yaml-ts-mode) . eglot-ensure)
  :bind (:map eglot-mode-map
         ("C-c c a" . eglot-code-actions)
         ("C-c c r" . eglot-rename)
         ("C-c c i" . eglot-find-implementation)
         ("C-c c t" . eglot-find-typeDefinition))
  :custom
  (eglot-autoshutdown t)
  (eglot-events-buffer-config '(:size 0 :format full)) ; no event log
  :config
  ;; A buffer-local defvar, not a defcustom, so :custom does not set it.
  (setq-default eglot-workspace-configuration #'my-eglot-workspace-configuration)
  ;; basedpyright asks to watch the Python stdlib and site-packages too.
  ;; kqueue needs one file descriptor per directory, so Emacs runs out
  ;; and the server exits.  Watch the project only.
  (setq eglot-watch-files-outside-project-root nil)
  ;; Eglot's own table maps marksman to markdown-mode only.
  (add-to-list 'eglot-server-programs
               '(markdown-ts-mode . ("marksman" "server")))
  ;; rass runs basedpyright and ruff behind one connection, so ruff's
  ;; diagnostics and code actions work next to basedpyright's.  Eglot's
  ;; own table asks for rass's python preset, which runs ty instead.
  (add-to-list 'eglot-server-programs
               `((python-mode python-ts-mode)
                 . ,(eglot-alternatives '(("rass" "basedruff")
                                          ("basedpyright-langserver" "--stdio"))))))

;; The most severe diagnostic of a line also shows at its end.
;; The indicators go in the right margin, because diff-hl uses the
;; left one.
(use-package flymake
  :custom
  (flymake-show-diagnostics-at-end-of-line 'short)
  (flymake-margin-indicator-position 'right-margin)
  :bind (:map flymake-mode-map
         ("M-n" . flymake-goto-next-error)
         ("M-p" . flymake-goto-prev-error)
         ("C-c c d" . flymake-show-buffer-diagnostics)
         ("C-c c D" . flymake-show-project-diagnostics)))

(defvar my-formatters
  '((python-ts-mode   "ruff" "format" "--stdin-filename" file "-")
    (bash-ts-mode     "shfmt" "--filename" file)
    (lua-ts-mode      "stylua" "--stdin-filepath" file "-")
    (markdown-ts-mode "prettier" "--stdin-filepath" file)
    (json-ts-mode     "prettier" "--stdin-filepath" file)
    (yaml-ts-mode     "prettier" "--stdin-filepath" file)
    (toml-ts-mode     "tombi" "format" "--stdin-filename" file "-"))
  "Formatter command per major mode, the same as in conform.nvim.
The command reads the buffer on stdin and writes the result to stdout.
The symbol `file' stands for the buffer's file name, which formatters
use to find their configuration.")

(defun my-command-args (command)
  "Return the arguments of COMMAND with `file' replaced by the file name."
  (let ((file (or buffer-file-name (buffer-name))))
    (mapcar (lambda (arg) (if (eq arg 'file) file arg)) (cdr command))))

(declare-function eglot-managed-p "eglot")

(defun my-format-buffer ()
  "Format the whole buffer, ignoring narrowing, with `my-formatters'.
The buffer is changed only if the formatter succeeds."
  (interactive)
  (let* ((command (alist-get major-mode my-formatters))
         (program (and command (executable-find (car command)))))
    (cond
     (program
      (let ((output (generate-new-buffer " *format*"))
            (errors (make-temp-file "format-errors")))
        (unwind-protect
            (save-restriction
              (widen)
              ;; The exit status is a string if the formatter was killed.
              (if (eql 0 (apply #'call-process-region nil nil program nil
                                (list output errors) nil
                                (my-command-args command)))
                  ;; Keeps point, marks and undo history intact.
                  (replace-region-contents (point-min) (point-max) output)
                (user-error "%s failed: %s" (car command)
                            (with-temp-buffer
                              (insert-file-contents errors)
                              (string-trim (buffer-string))))))
          (kill-buffer output)
          (delete-file errors))))
     (command (user-error "%s is not installed" (car command)))
     (t (user-error "No formatter for %s" major-mode)))))

(keymap-global-set "C-c c f" #'my-format-buffer)

(defvar my-linters
  '((lua-ts-mode      "selene" "--display-style" "quiet" "-")
    (markdown-ts-mode "markdownlint" "--stdin")
    (yaml-ts-mode     "yamllint" "--format" "parsable" "-"))
  "Linter command per major mode, the same as in nvim-lint.
Ruff is not here: it runs as a language server through rass.
The command reads the buffer on stdin and prints one problem per line
as FILE:LINE[:COL][:] MESSAGE.  A message that starts with `error' or
`[error' is an error, any other a warning.  The symbol `file' stands
for the buffer's file name.  The linter runs in the project root, where
it finds its configuration.")

(defvar-local my-lint--process nil
  "The running linter process of this buffer.")

(defun my-lint--diagnostics (source)
  "Parse the linter output in the current buffer into SOURCE diagnostics."
  (goto-char (point-min))
  (let (diagnostics)
    (while (re-search-forward
            "^[^:\n]*:\\([0-9]+\\)\\(?::\\([0-9]+\\)\\)?:? \\(.+\\)$" nil t)
      (let ((region (flymake-diag-region
                     source (string-to-number (match-string 1))
                     (and (match-string 2) (string-to-number (match-string 2)))))
            (text (match-string 3)))
        (when region
          (push (flymake-make-diagnostic
                 source (car region) (cdr region)
                 (if (string-match-p "\\`\\[?error" text) :error :warning)
                 text)
                diagnostics))))
    diagnostics))

(defun my-lint-flymake (report-fn &rest _args)
  "Flymake backend that runs the buffer's linter from `my-linters'.
Calls REPORT-FN with the problems, or with `:panic' when the linter
fails without reporting any."
  (let ((command (alist-get major-mode my-linters))
        (source (current-buffer))
        (default-directory (if-let* ((project (project-current)))
                               (project-root project)
                             default-directory)))
    (when (process-live-p my-lint--process)
      (kill-process my-lint--process))
    (setq my-lint--process
          (make-process
           :name "my-lint"
           :noquery t
           :connection-type 'pipe
           :buffer (generate-new-buffer " *my-lint*") ; stderr too
           :command (cons (car command) (my-command-args command))
           :sentinel
           (lambda (process _event)
             (unless (process-live-p process)
               (unwind-protect
                   (when (and (buffer-live-p source)
                              (eq process (buffer-local-value 'my-lint--process source)))
                     (with-current-buffer (process-buffer process)
                       (let ((diagnostics (my-lint--diagnostics source)))
                         (if (or diagnostics (eql 0 (process-exit-status process)))
                             (funcall report-fn diagnostics)
                           (funcall report-fn :panic :explanation
                                    (format "%s: %s" (car command)
                                            (string-trim (buffer-string))))))))
                 (kill-buffer (process-buffer process)))))))
    (process-send-region my-lint--process (point-min) (point-max))
    (process-send-eof my-lint--process)))

(defun my-lint-setup ()
  "Add the buffer's linter to Flymake next to Eglot's diagnostics.
Eglot replaces the Flymake backends when it starts, so this runs from
`eglot-managed-mode-hook'.  Every mode in `my-linters' uses Eglot."
  (when-let* (((eglot-managed-p))
              (command (alist-get major-mode my-linters)))
    (if (executable-find (car command))
        (add-hook 'flymake-diagnostic-functions #'my-lint-flymake nil t)
      (message "%s is not installed, so this buffer is not linted" (car command)))))

(add-hook 'eglot-managed-mode-hook #'my-lint-setup)

(provide 'init-lsp)
;;; init-lsp.el ends here
