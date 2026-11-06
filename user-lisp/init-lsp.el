;;; init-lsp.el --- Tree-sitter, Eglot, diagnostics and formatting -*- lexical-binding: t -*-

;;; Commentary:
;; Tree-sitter modes for all supported languages, grammars installed on
;; first use.  Eglot starts the Homebrew language servers that Eglot
;; already knows about.  Flymake shows their diagnostics.  C-c c f runs
;; the same formatters as conform.nvim.

;;; Code:

;; Use the *-ts-mode of every language that has one.  When a grammar
;; is missing, Emacs offers to build it (needs Xcode Command Line Tools).
(setopt treesit-enabled-modes t)

;; Emacs 31 ships markdown-ts-mode as experimental and does not autoload
;; it or associate it with .md files.
(autoload 'markdown-ts-mode "markdown-ts-mode" nil t)
(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-ts-mode))

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
  (eglot-workspace-configuration
   '(:basedpyright (:analysis (:typeCheckingMode "standard"))))
  :config
  ;; Eglot's own table maps marksman to markdown-mode only.
  (add-to-list 'eglot-server-programs
               '(markdown-ts-mode . ("marksman" "server"))))

(use-package flymake
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

(declare-function eglot-format-buffer "eglot")

(defun my-format-buffer ()
  "Format the buffer with its command in `my-formatters', else with Eglot.
Eglot is also used when the formatter is not installed.  The buffer is
changed only if the formatter succeeds."
  (interactive)
  (let* ((command (alist-get major-mode my-formatters))
         (program (and command (executable-find (car command))))
         (eglot (and (fboundp 'eglot-managed-p) (eglot-managed-p))))
    (cond
     (program
      (let ((file (or buffer-file-name (buffer-name)))
            (output (generate-new-buffer " *format*"))
            (errors (make-temp-file "format-errors")))
        (unwind-protect
            ;; The exit status is a string if the formatter was killed.
            (if (eql 0 (apply #'call-process-region nil nil program nil
                              (list output errors) nil
                              (mapcar (lambda (arg) (if (eq arg 'file) file arg))
                                      (cdr command))))
                ;; Keeps point, marks and undo history intact.
                (replace-region-contents (point-min) (point-max) output)
              (user-error "%s failed: %s" (car command)
                          (with-temp-buffer
                            (insert-file-contents errors)
                            (string-trim (buffer-string)))))
          (kill-buffer output)
          (delete-file errors))))
     (eglot
      (when command
        (message "%s is not installed, formatting with Eglot" (car command)))
      (eglot-format-buffer))
     (command (user-error "%s is not installed" (car command)))
     (t (user-error "No formatter for %s" major-mode)))))

(keymap-global-set "C-c c f" #'my-format-buffer)

(provide 'init-lsp)
;;; init-lsp.el ends here
