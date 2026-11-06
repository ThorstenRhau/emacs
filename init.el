;;; init.el --- Emacs 31 configuration entry point -*- lexical-binding: t -*-

;;; Commentary:
;; Installs missing packages, then loads the modules in user-lisp/ in
;; order.  Emacs byte-compiles user-lisp/ and adds it to `load-path'
;; before reading this file.

;;; Code:

;; Keep Customize output out of this file.
(setq custom-file (locate-user-emacs-file "custom.el"))
(load custom-file 'noerror 'nomessage)

;; Packages are listed here, not with `:ensure' or `:vc' in the modules.
;; Emacs compiles user-lisp/ before this file runs, and use-package
;; installs packages while compiling those keywords.  A Git install
;; started that way fails and leaves the package broken.
(setopt package-selected-packages '(corfu diff-hl magit)
        package-vc-selected-packages
        '((token :url "https://github.com/ThorstenRhau/token"
                 :lisp-dir "contrib/emacs")))
;; A failed install (for example offline on a first start) becomes a
;; message, so the built-in parts of the modules below still load.
(with-demoted-errors "Package install failed: %S"
  (unless (seq-every-p #'package-installed-p package-selected-packages)
    (package-refresh-contents)
    (package-install-selected-packages t))
  (package-vc-install-selected-packages))

(require 'init-editor)
(require 'init-terminal)
(require 'init-theme)
(require 'init-completion)
(require 'init-lsp)
(require 'init-navigation)
(require 'init-git)

;;; init.el ends here
