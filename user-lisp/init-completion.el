;;; init-completion.el --- Minibuffer and in-buffer completion -*- lexical-binding: t -*-

;;; Commentary:
;; Minibuffer: Vertico lists the candidates vertically, and Orderless
;; matches space-separated parts in any order, like fzf.
;; In-buffer: Corfu popup, which uses Emacs 31's terminal child frames,
;; with documentation beside the candidates.  Eglot feeds it LSP items.
;; Snippets: yasnippet.

;;; Code:

;; Loaded first: `setopt' checks `completion-styles' against the
;; styles that are defined.
(use-package orderless)

;; File names keep partial-completion, so ~/.c/em expands to ~/.config/emacs.
(setopt completion-styles '(orderless basic)
        completion-category-overrides '((file (styles basic partial-completion)))
        completion-ignore-case t
        read-buffer-completion-ignore-case t
        read-file-name-completion-ignore-case t
        completions-detailed t                 ; annotations in the list
        enable-recursive-minibuffers t
        tab-always-indent 'complete)           ; TAB indents, then completes

(use-package vertico
  :custom
  (vertico-cycle t)
  :init
  (vertico-mode))

(use-package corfu
  :custom
  (corfu-auto t)                               ; pop up while typing
  (corfu-auto-prefix 2)
  (corfu-cycle t)
  (corfu-popupinfo-delay '(0.5 . 0.2))
  :init
  (global-corfu-mode)
  (corfu-popupinfo-mode))

;; File names complete in code, prose and config files, like blink.cmp's
;; path source.  `cape-file' answers only when the text at point
;; contains a / and names an existing directory, so it goes before
;; Eglot's completion.  Eglot adds that in the buffer, which runs before
;; any global function, so `cape-file' is added in the buffer too.
(defun my-cape-file-first ()
  "Try file name completion before the buffer's other completions."
  (add-hook 'completion-at-point-functions #'cape-file -10 t))

(use-package cape
  :init
  (dolist (hook '(prog-mode-hook text-mode-hook conf-mode-hook))
    (add-hook hook #'my-cape-file-first)))

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
