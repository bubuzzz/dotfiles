# Emacs config

Vanilla Emacs 30 — `package.el`, `evil`, `eglot`. No framework, no `use-package`.
Shared between Arch (X11) and macOS; runs in the terminal (`emacs -nw` / `emacsclient -t`).

## Layout

```
early-init.el   package-quickstart switch (must be here, runs before package activation)
init.el         packages -> data -> wiring. The only file edited day to day.
custom.el       Customize-generated, loaded silently
lisp/           behavior, one concern per module
```

| module | owns |
|---|---|
| `config-backup` | backups / auto-saves / lockfiles -> `~/.cache/emacs/` |
| `config-ui` | frame, line numbers, font |
| `config-evil` | evil, evil-collection, clipboard, xclip |
| `config-shortcut` | general leader bindings |
| `config-completion` | vertico + vertico-directory path editing |
| `config-project` | project.el roots, remembered project list |
| `config-theme` | colorscheme ring + toggle |
| `config-statusline` | `mode-line-format` |
| `config-lsp` | eglot servers, keys, pyvenv |
| `config-org` | org, org-superstar, evil-org |
| `config-notebook` | jupyter / org-babel |

## The pattern

`init.el` holds three bands: the `my/packages` list, then `defvar` **data only**, then the
`(config-X-set ...)` calls. Modules hold **behavior only** and take their values as arguments —
a module never hardcodes a preference. Same structure as `~/.config/nvim`.

So: values go in `init.el`, mechanism goes in `lisp/`. Adding a language server or a keybinding
is a table entry, not a code change, and `init.el` alone describes the whole editor.

## How to

| task | do |
|---|---|
| add a package | append to `my/packages` — installs and refreshes quickstart on next start |
| add a leader key | one pair in `my/shortcuts` (`"key" command`) |
| add a mode-local key | entry under the keymap in `my/mode-shortcuts` |
| add an LSP server | one entry in `my/lsp-servers`; the hooks are derived from the modes |
| add a theme | append to `my/themes`; `<f5>` cycles the list |
| add a completion key | entry in `my/completion-keys` (bound in `vertico-map`) |
| change list height | `my/completion-count` |
| add a new concern | new `lisp/config-X.el` with `config-X-set`, then require + call it |

## Projects

Built-in `project.el`, no projectile. `SPC pa` drops a `.project` file in the current directory
and remembers it — that file is the root marker, so **you** decide what a project is, not git.
It wins over an enclosing git root, so marking a subdirectory of a repo makes that subdirectory
the project (and therefore the eglot workspace root for files under it).

`SPC pp` switches between remembered projects and goes straight to the file finder.
`my/project-switch-command` controls that; setting it back to a list restores project.el's
default action menu, where `e` is Eshell.

The list lives at `~/.cache/emacs/projects`, outside this directory.
To forget one: `M-x project-forget-project`.

## Gotchas

- **`M-x package-quickstart-refresh` after removing or upgrading a package.** Adding one is
  handled automatically; the other two leave stale autoloads and things break at startup.
- **Never install packages from `emacs --batch`.** `--batch` implies `--no-init-file`, so
  `early-init.el` never runs, `package-quickstart` reads as nil, and package.el *deletes*
  `package-quickstart.el` on exit. Startup silently falls back to the slow scan (~0.33s) with
  nothing to indicate why. Install from a normal session, or pass `(setq package-quickstart t)`
  explicitly in the batch form.
- **Don't add `(package-initialize)` back unguarded.** Emacs already activates packages before
  `init.el`; calling it again discards the quickstart file and doubles startup. The
  `(unless package-activated-list ...)` guard exists so `--batch`, which skips activation
  entirely, still works.
- **Keep things deferred.** `pyvenv`, `eglot`, `org`, `jupyter` must not load at startup —
  use `with-eval-after-load` or an autoloaded command, not `require`.
- **No `:which-key`.** Deliberately not installed; shortcut data is bare `"key" command` pairs.
- **Not a git repo.** No backups of this config exist anywhere.

## Startup

~0.20s. Check with `M-x emacs-init-time`, or from a shell:

```sh
emacs -nw --eval '(progn (princ (emacs-init-time) #'\''external-debugging-output) (kill-emacs))'
```

(`message` here would print to the echo area and be wiped when Emacs restores the terminal.)

If it regresses, the usual suspects are an eager `require` in a module, or a stale quickstart file.

## External deps

`basedpyright-langserver` and `jupyter` on `PATH` (per venv for jupyter), JetBrainsMono Nerd Font.
