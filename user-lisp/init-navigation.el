;;; init-navigation.el --- Files, projects, search and key hints -*- lexical-binding: t -*-

;;; Commentary:
;; project.el for files and grep, Consult for search with live preview,
;; Dired for directories, recentf for recent files and which-key for
;; key hints.

;;; Code:

;; Project search (C-x p g) and xref use ripgrep.
(setopt xref-search-program 'ripgrep
        grep-use-headings t)

;; Emacs parses rg output itself.  The shell's ripgrep config adds
;; --column, which shifts Consult's and xref's match positions.
(setenv "RIPGREP_CONFIG_PATH" nil)

(defun my-consult-flymake-project ()
  "Jump to a Flymake diagnostic from any buffer in the current project."
  (interactive)
  (consult-flymake t))

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
         ("C-c f f" . consult-find)
         ("C-c f r" . consult-recent-file)
         ("C-c s l" . consult-line)
         ("C-c s r" . consult-ripgrep)
         ("C-c s o" . consult-outline)
         ("C-c s i" . consult-imenu-multi)
         ("C-c s d" . consult-flymake)
         ("C-c s D" . my-consult-flymake-project))
  :custom
  (xref-show-xrefs-function #'consult-xref)
  (xref-show-definitions-function #'consult-xref))

;; Dired: GNU ls from coreutils with directories first.  Deletions move
;; to the macOS Trash.  C-x C-j jumps to the current file's directory;
;; C-x C-q makes the listing editable, so renames are text edits.
;; C-c - is the same jump, on the key Oil uses in Neovim.
(setopt insert-directory-program "gls"
        dired-listing-switches "-alh --group-directories-first"
        dired-dwim-target t
        dired-kill-when-opening-new-dired-buffer t
        delete-by-moving-to-trash t
        wdired-allow-to-change-permissions t)
(keymap-global-set "C-c -" #'dired-jump)

(which-key-mode 1)
(which-key-add-key-based-replacements
  "C-c @" "fold"
  "C-c c" "code"
  "C-c f" "files"
  "C-c s" "search"
  "C-c t" "toggle")

(provide 'init-navigation)
;;; init-navigation.el ends here
