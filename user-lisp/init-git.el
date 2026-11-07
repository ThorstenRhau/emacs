;;; init-git.el --- Magit and change markers -*- lexical-binding: t -*-

;;; Commentary:
;; Magit is the Git interface (C-x g for status).  diff-hl shows change
;; markers in the margin, moves between hunks with C-x v [ and
;; C-x v ], and C-x v * shows the hunk at point.  With `repeat-mode'
;; (init-editor), more [ and ] keep moving between hunks.  Magit's
;; C-c M-g menu has blame and the file's log.

;;; Code:

;; Magit's autoloads bind C-x g and C-c M-g; load the rest on first use.
(use-package magit
  :defer t)

(use-package diff-hl
  :hook (magit-post-refresh . diff-hl-magit-post-refresh)
  :init
  (global-diff-hl-mode 1)
  (setopt diff-hl-autohide-margin t)
  (diff-hl-margin-mode 1)                      ; terminals have no fringe
  (diff-hl-flydiff-mode 1))                    ; update before saving

(provide 'init-git)
;;; init-git.el ends here
