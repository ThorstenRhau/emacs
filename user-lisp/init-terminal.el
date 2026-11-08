;;; init-terminal.el --- Ghostty integration -*- lexical-binding: t -*-

;;; Commentary:
;; Emacs runs in Ghostty, so the font, ligatures and Nerd Font glyphs
;; come from Ghostty's own configuration.  This module only tells Emacs
;; which xterm extensions Ghostty supports.

;;; Code:

;; Ghostty supports these xterm extensions, but its device-attribute
;; reply does not advertise all of them, so Emacs' default `check'
;; would miss some:
;;   modifyOtherKeys   keys such as C-, C-RET and C-M-% reach Emacs
;;   reportBackground  Emacs learns whether Ghostty is light or dark
;;                     at startup (used by init-theme)
;;   setSelection      kills are copied to the macOS clipboard (OSC 52)
;; Reading the clipboard over OSC 52 is left out: Ghostty asks for
;; permission each time.  Paste from macOS with Cmd-V instead.
(when (equal (getenv "TERM") "xterm-ghostty")
  (setopt xterm-extra-capabilities
          '(modifyOtherKeys reportBackground setSelection))
  ;; Emacs 31 enables the mouse only on its allowlist of terminals,
  ;; which leaves out Ghostty.  Shift-drag still uses Ghostty's own
  ;; selection.
  (xterm-mouse-mode 1)
  ;; The wheel bindings are missing at start-up in the terminal, so
  ;; scrolling reports "<wheel-down> is undefined".  Calling the mode
  ;; adds them.  Tilt scrolling also binds <wheel-left> and <wheel-right>
  ;; (sideways trackpad movement).
  (setopt mouse-wheel-tilt-scroll nil)
  (mouse-wheel-mode 1))

;; Emacs 31 turns on `xterm-mouse-mode' in Ghostty by default.  Hold
;; Shift while dragging to use Ghostty's own selection instead.

(provide 'init-terminal)
;;; init-terminal.el ends here
