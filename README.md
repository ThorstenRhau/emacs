# emacs

Personal Emacs 31.1 configuration for macOS, used in the Ghostty terminal.
Vanilla Emacs keys, built-in features first, four packages.

## Installation

Install Emacs and the tools with [Homebrew](https://brew.sh/):

```sh
brew install emacs git ripgrep coreutils \
  basedpyright bash-language-server lua-language-server marksman \
  vscode-langservers-extracted yaml-language-server tombi \
  ruff shfmt stylua prettier
```

Building tree-sitter grammars needs the Xcode Command Line Tools
(`xcode-select --install`).

Start `emacs` in Ghostty. The first start installs the packages from GNU ELPA
and NonGNU ELPA. The first time you open a file in a language without a
grammar, Emacs asks whether to build it.

Ghostty must send Option as Meta (`macos-option-as-alt = left`).

## Layout

| File                           | Purpose                                                       |
| ------------------------------ | ------------------------------------------------------------- |
| `init.el`                      | Custom file, module order                                     |
| `user-lisp/init-editor.el`     | Editing defaults, line numbers, backups, history              |
| `user-lisp/init-terminal.el`   | xterm extensions that Ghostty supports                        |
| `user-lisp/init-theme.el`      | Token Meridian, switched by the terminal's appearance reports |
| `user-lisp/init-completion.el` | `fido-vertical-mode` and Corfu                                |
| `user-lisp/init-lsp.el`        | Tree-sitter modes, Eglot, Flymake, formatting                 |
| `user-lisp/init-navigation.el` | project.el, Dired, ripgrep, recentf, which-key                |
| `user-lisp/init-git.el`        | Magit and diff-hl                                             |

Emacs 31 byte-compiles `user-lisp/` at startup, before it loads `init.el`, and
recompiles files that changed. After upgrading Emacs, run
`C-u M-x prepare-user-lisp` and restart.

Packages: `token` (from its Git repository), `corfu`, `magit`, `diff-hl`, and
Magit's dependencies.

## Keys

Standard Emacs keys, plus these under the user prefix `C-c`:

| Key          | Command                      |
| ------------ | ---------------------------- |
| `C-c c a`    | Code action                  |
| `C-c c r`    | Rename symbol                |
| `C-c c i`    | Find implementation          |
| `C-c c t`    | Find type definition         |
| `C-c c f`    | Format buffer                |
| `C-c c d`    | Buffer diagnostics           |
| `C-c c D`    | Project diagnostics          |
| `C-c f r`    | Recent files                 |
| `C-c o`      | Open file in its macOS app   |
| `C-c t w`    | Toggle word wrap             |
| `C-c t l`    | Toggle line numbers          |
| `M-n`, `M-p` | Next and previous diagnostic |
