;;; init-theme.el --- Token Meridian, following the system appearance -*- lexical-binding: t -*-

;;; Commentary:
;; Switches between token-meridian-dark and token-meridian-light, from
;; the Emacs port of Token that init.el installs.
;;
;; Ghostty follows the macOS appearance.  At startup Emacs reads
;; Ghostty's background color (see init-terminal).  After that, Ghostty
;; sends a color scheme report (DEC mode 2031) whenever the appearance
;; changes, so nothing polls.

;;; Code:

(defun my-token-apply (appearance)
  "Load the Token variant for APPEARANCE, `light' or `dark'."
  (let ((theme (if (eq appearance 'light)
                   'token-light
                 'token-dark)))
    (unless (memq theme custom-enabled-themes)
      (mapc #'disable-theme custom-enabled-themes)
      (load-theme theme t))))

(defun my-token-decode-report (&optional _prompt)
  "Translate a color scheme report that starts with ESC [ ?.
Ghostty sends ESC [ ? 997 ; 1 n for dark and ESC [ ? 997 ; 2 n for
light.  The rest of the report is read here, because Emacs would
otherwise take the `?' as a request for help on the ESC [ prefix.
Any other sequence is passed on unchanged."
  (let (events event)
    (while (and (setq event (read-event nil nil 0.1))
                (progn (push event events) (characterp event))
                (not (eq event ?n))))
    (pcase (nreverse events)
      ('(?9 ?9 ?7 ?\; ?1 ?n) [token-appearance-dark])
      ('(?9 ?9 ?7 ?\; ?2 ?n) [token-appearance-light])
      (other (vconcat "\e[?" other)))))

(defun my-token-appearance-changed ()
  "Apply the appearance that the terminal reported."
  (interactive)
  ;; Keep the previous command, so C-y M-y and repeated C-k still work
  ;; when a report arrives between them.
  (setq this-command last-command)
  (my-token-apply (if (eq last-command-event 'token-appearance-light)
                      'light
                    'dark)))

(keymap-global-set "<token-appearance-dark>" #'my-token-appearance-changed)
(keymap-global-set "<token-appearance-light>" #'my-token-appearance-changed)

(defun my-token-follow-terminal ()
  "Match the theme to the terminal and, in Ghostty, follow appearance changes."
  (my-token-apply (terminal-parameter nil 'background-mode))
  (when (equal (tty-type) "xterm-ghostty")
    (define-key input-decode-map "\e[?" #'my-token-decode-report)
    (send-string-to-terminal "\e[?2031h")
    ;; Emacs sends these when it suspends, resumes and exits.  Turning
    ;; the reports off keeps them from being typed into the shell; on
    ;; resume, ESC [ ? 996 n asks for the appearance, which may have
    ;; changed.
    (push "\e[?2031l" (terminal-parameter nil 'tty-mode-reset-strings))
    (push "\e[?2031h\e[?996n" (terminal-parameter nil 'tty-mode-set-strings))))

(add-hook 'tty-setup-hook #'my-token-follow-terminal)

(provide 'init-theme)
;;; init-theme.el ends here
