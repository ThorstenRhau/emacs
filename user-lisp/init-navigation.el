;;; init-navigation.el --- Files, projects, search and key hints -*- lexical-binding: t -*-

;;; Commentary:
;; Built-in replacements for fzf-lua, oil.nvim and mini.clue:
;; project.el for files and grep, Dired for directories, recentf for
;; recent files and which-key for key hints.

;;; Code:

;; Project search (C-x p g) and xref use ripgrep.
(setopt xref-search-program 'ripgrep
        grep-use-headings t)

(keymap-global-set "C-c f r" #'recentf-open)

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
