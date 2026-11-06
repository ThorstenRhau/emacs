;;; init-completion.el --- Minibuffer and in-buffer completion -*- lexical-binding: t -*-

;;; Commentary:
;; Minibuffer: built-in `fido-vertical-mode' (fuzzy, vertical list).
;; In-buffer: Corfu popup, which uses Emacs 31's terminal child frames,
;; with documentation beside the candidates.  Eglot feeds it LSP items.
;; Snippets: yasnippet.

;;; Code:

(setopt completion-styles '(basic partial-completion flex)
        completion-ignore-case t
        read-buffer-completion-ignore-case t
        read-file-name-completion-ignore-case t
        completions-detailed t                 ; annotations in the list
        enable-recursive-minibuffers t
        tab-always-indent 'complete)           ; TAB indents, then completes

(fido-vertical-mode 1)

(use-package corfu
  :custom
  (corfu-auto t)                               ; pop up while typing
  (corfu-auto-prefix 2)
  (corfu-cycle t)
  (corfu-popupinfo-delay '(0.5 . 0.2))
  :init
  (global-corfu-mode)
  (corfu-popupinfo-mode))

;; Own snippets live in snippets/<major-mode>/ in this directory, next
;; to the yasnippet-snippets collection.  TAB expands a snippet key and
;; moves between fields; C-c & holds the snippet commands.  Eglot
;; expands LSP snippet completions with it.
(use-package yasnippet
  :init
  (yas-global-mode 1))

(use-package yasnippet-snippets
  :after yasnippet)

(provide 'init-completion)
;;; init-completion.el ends here
