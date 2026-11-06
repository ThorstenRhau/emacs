;;; init-editor.el --- Editing defaults -*- lexical-binding: t -*-

;;; Commentary:
;; Built-in options that match the Neovim setup: relative line numbers,
;; cursor line, scroll margin, no wrapping in code, spaces for indent,
;; EditorConfig, persistent history and cursor positions.

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
        recentf-max-saved-items 200)

(menu-bar-mode -1)
(column-number-mode 1)
(global-hl-line-mode 1)                        ; cursorline
(delete-selection-mode 1)
(editorconfig-mode 1)                          ; .editorconfig takes precedence
(global-auto-revert-mode 1)
(save-place-mode 1)                            ; reopen files at the last position
(savehist-mode 1)                              ; minibuffer history
(recentf-mode 1)

;; Line numbers and trailing whitespace in code only.
(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(add-hook 'prog-mode-hook (lambda () (setq show-trailing-whitespace t)))

;; Prose wraps at word boundaries.
(add-hook 'text-mode-hook #'visual-line-mode)

;; Commit messages: 72-column guide.
(add-hook 'git-commit-mode-hook
          (lambda ()
            (setq fill-column 72)
            (display-fill-column-indicator-mode 1)))

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

(keymap-global-set "C-c o" #'my-open-externally)
(keymap-global-set "C-c t w" #'visual-line-mode)
(keymap-global-set "C-c t l" #'display-line-numbers-mode)

(provide 'init-editor)
;;; init-editor.el ends here
