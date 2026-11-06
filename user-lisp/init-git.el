;;; init-git.el --- Magit and change markers -*- lexical-binding: t -*-

;;; Commentary:
;; Magit replaces Neogit (C-x g for status).  diff-hl replaces gitsigns:
;; change markers in the margin, hunk navigation with C-x v [ and
;; C-x v ], and C-x v * to show the hunk at point.  With `repeat-mode'
;; (init-editor), more [ and ] keep moving between hunks.  Magit's
;; C-c M-g menu has blame and the file's log.

;;; Code:

(use-package magit)

(use-package diff-hl
  :hook (magit-post-refresh . diff-hl-magit-post-refresh)
  :init
  (global-diff-hl-mode 1)
  (diff-hl-margin-mode 1)                      ; terminals have no fringe
  (diff-hl-flydiff-mode 1))                    ; update before saving

(provide 'init-git)
;;; init-git.el ends here
