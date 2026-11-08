# emacs

Personal Emacs 31.1 configuration for macOS, used in the Ghostty terminal.
Vanilla Emacs keys, built-in features first, ten packages.

## Installation

Install Emacs and the tools with [Homebrew](https://brew.sh/):

```sh
brew install emacs git ripgrep coreutils aspell \
  basedpyright bash-language-server lua-language-server marksman \
  vscode-langservers-extracted yaml-language-server tombi \
  ruff shfmt stylua prettier selene markdownlint-cli yamllint uv
uv tool install rassumfrassum
```

[rass](https://github.com/joaotavora/rassumfrassum) runs basedpyright and ruff
behind one Eglot connection, so Python gets ruff's diagnostics and code actions
too.

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
| `user-lisp/init-editor.el`     | Editing defaults, folding, spelling, sessions, backups        |
| `user-lisp/init-terminal.el`   | xterm extensions that Ghostty supports                        |
| `user-lisp/init-theme.el`      | Token Meridian, switched by the terminal's appearance reports |
| `user-lisp/init-completion.el` | Vertico, Orderless, Corfu, Cape and yasnippet                 |
| `user-lisp/init-lsp.el`        | Tree-sitter modes, Eglot, JSON schemas, linters, formatting   |
| `user-lisp/init-navigation.el` | project.el, Consult, Dired, ripgrep, recentf, which-key       |
| `user-lisp/init-git.el`        | Magit and diff-hl                                             |

Emacs 31 byte-compiles `user-lisp/` at startup, before it loads `init.el`, and
recompiles files that changed. After upgrading Emacs, run
`C-u M-x prepare-user-lisp` and restart.

Packages: `token` (from its Git repository), `vertico`, `orderless`, `consult`,
`corfu`, `cape`, `yasnippet`, `yasnippet-snippets`, `magit`, `diff-hl`, and
Magit's dependencies.

In the minibuffer, Orderless matches space-separated parts in any order. File
names also expand partial paths, so `~/.c/em` finds `~/.config/emacs`.

Consult remaps the standard keys `C-x b`, `C-x 4 b`, `C-x p b`, `C-x r b`,
`M-y`, `M-g g` and `M-g i` to its versions with live preview, and xref lists
results through it. `yasnippet-snippets` supplies snippets for most languages;
put your own in `snippets/<major-mode>/`. `TAB` expands them.

In code, prose and config files, Corfu also completes file names once the text
at point contains a `/`.

Flymake shows the language server's diagnostics and, for Lua, Markdown and
YAML, those of selene, markdownlint and yamllint. They show at the end
of the line and in the right margin; diff-hl uses the left one. The linters run
in the project root, where they find their configuration.

JSON files are validated against the [SchemaStore](https://www.schemastore.org)
schema that matches their name. The first JSON file you open downloads the
catalog to `schemastore.json`; `C-c l` refreshes it.

Open files and windows are saved on exit. `C-c S` restores them. With
`repeat-mode`, keep pressing the last key of a command such as `C-x v ]` to
repeat it. Magit's `C-c M-g` has blame and the log of the current file.

## Keys

Standard Emacs keys, plus these under the user prefix `C-c`:

| Key          | Command                      |
| ------------ | ---------------------------- |
| `C-c c a`    | Code action                  |
| `C-c c r`    | Rename symbol                |
| `C-c c i`    | Find implementation          |
| `C-c c t`    | Find type definition         |
| `C-c c f`    | Format buffer                |
| `C-c c l`    | Align by regexp              |
| `C-c c d`    | Buffer diagnostics           |
| `C-c c D`    | Project diagnostics          |
| `C-c f r`    | Recent files                 |
| `C-c s l`    | Search lines in buffer       |
| `C-c s r`    | Ripgrep in project           |
| `C-c s o`    | Jump to outline heading      |
| `C-c s i`    | Imenu across project buffers |
| `C-c @`      | Folding commands (hideshow)  |
| `C-c &`      | Snippet commands (yasnippet) |
| `C-c o`      | Open file in its macOS app   |
| `C-c S`      | Restore the last session     |
| `C-c l`      | Upgrade packages and schemas |
| `C-c t s`    | Toggle spelling              |
| `C-c t w`    | Toggle word wrap             |
| `C-c t l`    | Toggle line numbers          |
| `C-c t h`    | Toggle inlay hints (Eglot)   |
| `M-n`, `M-p` | Next and previous diagnostic |
