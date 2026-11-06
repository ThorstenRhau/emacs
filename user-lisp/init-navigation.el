;;; init-navigation.el --- Files, projects, search and key hints -*- lexical-binding: t -*-

;;; Commentary:
;; project.el for files and grep, Consult for search with live preview,
;; Dired for directories, recentf for recent files and which-key for
;; key hints.

;;; Code:

;; Project search (C-x p g) and xref use ripgrep.
(setopt xref-search-program 'ripgrep
        grep-use-headings t)

;; Consult takes over the standard keys through remaps, so C-x b,
;; C-x p b, M-y, M-g g and M-g i keep working with preview.  Search
;; commands that have no standard key go under C-c s.
(use-package consult
  :bind (([remap switch-to-buffer] . consult-buffer)
         ([remap switch-to-buffer-other-window] . consult-buffer-other-window)
         ([remap project-switch-to-buffer] . consult-project-buffer)
         ([remap bookmark-jump] . consult-bookmark)
         ([remap yank-pop] . consult-yank-pop)
         ([remap goto-line] . consult-goto-line)
         ([remap imenu] . consult-imenu)
         ("C-c f r" . consult-recent-file)
         ("C-c s l" . consult-line)
         ("C-c s r" . consult-ripgrep)
         ("C-c s o" . consult-outline)
         ("C-c s i" . consult-imenu-multi))
  :custom
  (xref-show-xrefs-function #'consult-xref)
  (xref-show-definitions-function #'consult-xref))

;; Dired: GNU ls from coreutils with directories first, else macOS ls.
;; Deletions move to the macOS Trash.  C-x C-j jumps to the current
;; file's directory; C-x C-q makes the listing editable like oil.nvim.
(if (executable-find "gls")
    (setopt insert-directory-program "gls"
            dired-listing-switches "-alh --group-directories-first")
  (setopt dired-listing-switches "-alh"))
(setopt dired-dwim-target t
        dired-kill-when-opening-new-dired-buffer t
        delete-by-moving-to-trash t
        wdired-allow-to-change-permissions t)

(which-key-mode 1)

(provide 'init-navigation)
;;; init-navigation.el ends here
