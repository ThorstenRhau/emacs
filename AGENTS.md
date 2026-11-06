# AGENTS.md

Personal Emacs 31.1 config for macOS, used in the Ghostty terminal. `README.md`
has the install steps, module table and key bindings.

## Conventions

- Vanilla Emacs keys, built-in features first. Four packages: `token`, `corfu`,
  `magit`, `diff-hl`. Ask before adding one.
- Modules live in `user-lisp/init-*.el` and are required in order from
  `init.el`. A new module needs a `require` there and a row in the README
  layout table.
- User keys go under `C-c`. Update the README key table when you add or change one.
- List packages in `init.el` (`package-selected-packages`,
  `package-vc-selected-packages`), never with `:ensure` or `:vc` in a module.
  Emacs compiles `user-lisp/` before `init.el` runs, and an install started
  during that compile fails and leaves the package broken.
- Formatters are the `my-formatters` alist in `user-lisp/init-lsp.el`. The
  README install list must name each tool.

## Checks

- Start-up check: `emacs --batch --init-directory . --eval '(message "ok")'`
  from the repo root. It should print `ok` with no warnings.
- Emacs byte-compiles `user-lisp/` at start-up. Fix any compile warning.
- Interactive behavior (theme switching, Eglot, mouse, clipboard) needs a real
  Emacs in Ghostty. Say so when you could not verify it.

## Gotchas

- This directory is the live Emacs config. `elpa/`, `tree-sitter/`, `custom.el`,
  `history`, `*.eld` and `*.elc` are generated and gitignored. Do not edit or
  commit them.
- Customize output goes to `custom.el`, not `init.el`.
- `init-terminal.el` sets `xterm-extra-capabilities` only when `TERM` is
  `xterm-ghostty`.
