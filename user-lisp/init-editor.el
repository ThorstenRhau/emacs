;;; init-editor.el --- Editing defaults -*- lexical-binding: t -*-

;;; Commentary:
;; Built-in options that match the Neovim setup: relative line numbers,
;; cursor line, scroll margin, no wrapping in code, spaces for indent,
;; EditorConfig, persistent history and cursor positions.  Also
;; folding, spelling, sessions and a few helpers from the Neovim setup.

;;; Code:

(setopt inhibit-startup-screen t
        ring-bell-function #'ignore
        use-short-answers t
        indent-tabs-mode nil                   ; expandtab
        require-final-newline t
        sentence-end-double-space nil
        scroll-margin 10                       ; scrolloff
        scroll-conservatively 101
        truncate-lines t                       ; nowrap
        display-line-numbers-type 'relative
        display-line-numbers-width 3
        vc-follow-symlinks t                   ; for Stow-managed dotfiles
        recentf-max-saved-items 200
        ;; Minor modes share one … in the mode line, except Flymake,
        ;; whose lighter holds the diagnostic counts.
        mode-line-collapse-minor-modes '(not flymake-mode))

(menu-bar-mode -1)
(column-number-mode 1)
(global-hl-line-mode 1)                        ; cursorline
(delete-selection-mode 1)
(editorconfig-mode 1)                          ; .editorconfig takes precedence
(global-auto-revert-mode 1)
(save-place-mode 1)                            ; reopen files at the last position
(savehist-mode 1)                              ; minibuffer history
(recentf-mode 1)
(repeat-mode 1)                                ; C-x v ] ] ] and similar

;; Line numbers, trailing whitespace and tab marks in code only, like
;; listchars.  Emacs already highlights non-breaking spaces.
(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(add-hook 'prog-mode-hook (lambda () (setq show-trailing-whitespace t)))
(setopt whitespace-style '(tab-mark)
        whitespace-display-mappings '((tab-mark ?\t [?→ ?\t])))
(add-hook 'prog-mode-hook #'whitespace-mode)

;; Folding under C-c @, all open at first.  Tree-sitter modes fold
;; their syntax nodes.
(add-hook 'prog-mode-hook #'hs-minor-mode)

;; Spelling with aspell: in code, comments and strings only.
(setopt ispell-dictionary "en_US")

(defun my-toggle-spelling ()
  "Toggle spell checking; in code, check only comments and strings."
  (interactive)
  (cond ((bound-and-true-p flyspell-mode) (flyspell-mode -1))
        ((derived-mode-p 'prog-mode) (flyspell-prog-mode))
        (t (flyspell-mode 1))))

;; Prose wraps at word boundaries.
(add-hook 'text-mode-hook #'visual-line-mode)

;; Commit messages: 72-column guide and spelling.
(add-hook 'git-commit-mode-hook
          (lambda ()
            (setq fill-column 72)
            (display-fill-column-indicator-mode 1)
            (flyspell-mode 1)))

;; Sessions: the open files and windows are saved on exit, and C-c S
;; restores them, like the Neovim setup.
(setopt desktop-path (list user-emacs-directory))

(defvar desktop-file-modtime)
(declare-function desktop-full-file-name "desktop")

(defun my-desktop-save ()
  "Save the session to `user-emacs-directory', except in batch mode.
Like Neovim's mksession!, the last Emacs to exit wins."
  (unless noninteractive
    (require 'desktop)
    ;; `desktop-save' asks before it overwrites a session file that
    ;; this Emacs did not load.  Claiming the file's current time as
    ;; the loaded one skips that question.
    (let ((desktop-file-modtime
           (file-attribute-modification-time
            (file-attributes (desktop-full-file-name user-emacs-directory)))))
      (desktop-save user-emacs-directory t))))

(add-hook 'kill-emacs-hook #'my-desktop-save)

;; Backups and auto-saves go under the config directory, not next to files.
(let ((auto-save-dir (locate-user-emacs-file "auto-save/")))
  (make-directory auto-save-dir t)
  (setopt backup-directory-alist `(("." . ,(locate-user-emacs-file "backups/")))
          auto-save-file-name-transforms `((".*" ,auto-save-dir t))
          backup-by-copying t
          create-lockfiles nil))

(defun my-open-externally ()
  "Open the current file with the default macOS application."
  (interactive)
  (unless buffer-file-name
    (user-error "Buffer is not visiting a file"))
  (call-process "open" nil 0 nil buffer-file-name))

(declare-function my-json-schemas-update "init-lsp")

(defun my-package-upgrade-all ()
  "Upgrade the packages from the archives and from Git.
Also refresh the SchemaStore catalog, as schemastore.nvim does."
  (interactive)
  (package-upgrade-all t)
  (package-vc-upgrade-all)
  (my-json-schemas-update))

(keymap-global-set "C-c o" #'my-open-externally)
(keymap-global-set "C-c c l" #'align-regexp)
(keymap-global-set "C-c l" #'my-package-upgrade-all)
(keymap-global-set "C-c S" #'desktop-read)
(keymap-global-set "C-c t s" #'my-toggle-spelling)
(keymap-global-set "C-c t w" #'visual-line-mode)
(keymap-global-set "C-c t l" #'display-line-numbers-mode)

(provide 'init-editor)
;;; init-editor.el ends here
