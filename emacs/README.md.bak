# Emacs config

Vanilla Emacs 30 — `package.el`, `evil`, `eglot`. No framework, no `use-package`.
Shared between Arch (X11) and macOS; runs in the terminal (`emacs -nw` / `emacsclient -t`).

## Layout

```
early-init.el   cache redirects, package-quickstart, first-frame appearance (runs before init)
init.el         packages -> data -> wiring. The only file edited day to day.
custom.el       Customize-generated, loaded silently
lisp/           behavior, one concern per module
banner.txt      dashboard splash
```

This directory is **source only** — nothing Emacs writes at runtime lands here, so the whole
folder can be copied into a dotfiles repo as-is. See [State](#state).

| module | owns |
|---|---|
| `config-cache` | every runtime-written file -> `~/.cache/emacs/` |
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
| `config-latex` | org → PDF export engine (`org-latex-pdf-process`) |

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

**Eglot only starts inside a project** (`config-lsp--ensure-in-project` guards `eglot-ensure` on
`project-current`). Open a Python file that is in no project and no git repo — a loose file in
`~`, say — and eglot stays off. Without this, eglot roots the transient workspace at the file's
own directory, so a file in `~` makes basedpyright index the whole home tree and pin a CPU core.
To get LSP on such a file, mark its directory with `SPC pa`.

`SPC pp` switches between remembered projects and goes straight to the file finder.
`my/project-switch-command` controls that; setting it back to a list restores project.el's
default action menu, where `e` is Eshell.

The list lives at `~/.cache/emacs/projects`, outside this directory.
To forget one: `M-x project-forget-project`.

## State

Everything Emacs writes lives in `~/.cache/emacs/` (`$XDG_CACHE_HOME/emacs/`), never in this
directory. `my/cache-dir` is defined in `early-init.el` and reused by `init.el`.

| goes to `~/.cache/emacs/` | set by | variable |
|---|---|---|
| `elpa/` | `early-init.el` | `package-user-dir` |
| `eln-cache/` | `early-init.el` | `startup-redirect-eln-cache` |
| `package-quickstart.el` | `early-init.el` | `package-quickstart-file` |
| `backup/`, `auto-save/`, `lock/` | `config-cache` | `backup-directory-alist` and friends |
| `auto-save-list/` | `config-cache` | `auto-save-list-file-prefix` |
| `history`, `recentf` | `config-cache` | `savehist-file`, `recentf-save-file` |
| `eshell/`, `tramp`, `url/` | `config-cache` | `eshell-directory-name`, … |
| `transient/` | `config-cache` | `transient-history-file`, … |
| `projects` | `config-project` | `project-list-file` |

The three in `early-init.el` **cannot** move to a module: packages are activated and the
quickstart file is loaded before `init.el` is read, and the eln cache must be redirected before
anything is natively compiled.

`config-cache` sets its variables with plain `setq` while the owning libraries are still unloaded.
That is deliberate — `defcustom` does not overwrite an already-bound value, so the redirect wins
without forcing a `require` at startup.

To relocate the cache, change `my/cache-dir` in `early-init.el`, move the old directory to the new
path, and run `M-x package-quickstart-refresh`.

Deleting `~/.cache/emacs/` loses nothing but time: the next start reinstalls packages from
`my/packages` and recompiles. Only the `.el` sources here are irreplaceable.

## Gotchas

- **`M-x package-quickstart-refresh` after removing or upgrading a package.** Adding one is
  handled automatically; the other two leave stale autoloads and things break at startup.
- **Never install packages from `emacs --batch`.** `--batch` implies `--no-init-file`, so
  `early-init.el` never runs, `package-quickstart` reads as nil, and package.el *deletes*
  `package-quickstart.el` on exit. Startup silently falls back to the slow scan (~0.33s) with
  nothing to indicate why. Install from a normal session, or pass `(setq package-quickstart t)`
  explicitly in the batch form.
- **Never sync `package-quickstart.el`, `elpa/` or `eln-cache/` between machines.** They are
  generated caches of *absolute* paths; living in `~/.cache/emacs/` now keeps them out of the way,
  so this only bites if one is ever copied back by hand. A quickstart file made on the Mac points
  `load-path` at `/Users/...` directories that don't exist on Arch, *and* sets
  `package-activated-list` — which suppresses the `package-initialize` guard below (so the real
  `elpa/` is never activated) and makes `package-installed-p` take its quickstart fast-path, so
  every package reports as installed and the install loop in `init.el` does nothing. Startup then
  dies on the first `require` with a bare `Cannot open load file: evil`. Recovery: delete
  `package-quickstart.el` and `.elc`, start Emacs (the guard fires, local packages activate,
  anything missing installs), then `M-x package-quickstart-refresh`.
- **Don't add `(package-initialize)` back unguarded.** Emacs already activates packages before
  `init.el`; calling it again discards the quickstart file and doubles startup. The
  `(unless package-activated-list ...)` guard exists so `--batch`, which skips activation
  entirely, still works.
- **Keep things deferred.** `pyvenv`, `eglot`, `org`, `jupyter` must not load at startup —
  use `with-eval-after-load` or an autoloaded command, not `require`.
- **`ob-jupyter` shells out to `jupyter`, and errors when it is absent.** It calls
  `jupyter-kernelspecs` (which runs the `jupyter` program) from an `org-mode-hook` — so opening any
  org file with no venv active prints `Error retrieving kernelspecs` — and again from an
  `org-export-before-processing-functions` hook, where the error is *not* demoted and aborts
  `C-c C-e l p` before LaTeX runs. There is no `defcustom` to disable either. `config-notebook`
  guards the single choke point instead: an `:around` advice on `jupyter-kernelspecs`
  (`config-notebook--when-jupyter`) runs the real function only `(when (executable-find "jupyter"))`
  and returns nil otherwise, so both the open and export paths are silent with no jupyter, and a
  jupyter-capable venv works normally. One advice covers every caller and depends on no ob-jupyter
  hook symbols.
- **Don't set `frame-inhibit-implied-resize`.** `dashboard-vertically-center-content` measures
  `window-pixel-height` and `line-pixel-height` once and inserts that many literal newlines, then
  never recomputes. Anything that changes frame geometry or font metrics after that render leaves
  the padding wrong for good — too much of it drops the banner to the bottom of the frame.
- **`my/startup-background` must match the first theme in `my/themes`.** On a GUI the frame is
  created and painted before `init.el` runs, so without it Emacs shows a white frame until the
  theme loads. `early-init.el` pre-paints the frame via `default-frame-alist`, and the menu bar,
  tool bar and scroll bars are set to zero there too so they are never drawn rather than removed
  afterwards by `config-ui`. Colours are only applied when `initial-window-system` is non-nil, so
  `emacs -nw` keeps the terminal's own background. Reorder `my/themes` and this needs updating —
  read the new value with `(face-attribute 'default :background)`.
- **Don't force the dashboard with `initial-buffer-choice`.** `dashboard-setup-startup-hook`
  already shows the dashboard, but only `(when (< (length command-line-args) 2))` — i.e. when no
  file was passed, which is exactly what you want. Setting `initial-buffer-choice #'dashboard-open`
  overrides that guard and prepends the dashboard unconditionally; with a file argument Emacs then
  has two buffers to show and splits the frame (dashboard on one side, file on the other). The
  emacsclient/daemon case is covered separately by `server-after-make-frame-hook`. (`-nw` is
  stripped from `command-line-args`, so bare `emacs -nw` still counts as no-file and shows it.)
- **`initial-major-mode` is `fundamental-mode` on purpose.** `*scratch*` exists until the dashboard
  startup hook swaps it out, and Emacs sets its major mode *after* init.el has loaded. Leave it as
  `lisp-interaction-mode` and it inherits `prog-mode-hook`, so the line-number gutter switches on
  for the frame `*scratch*` is briefly current and then vanishes with the buffer — a flash on every
  start. `config-dashboard` sets it. `dashboard-mode` itself derives from `special-mode` and
  already disables line numbers, so it needs no hook of its own.
- **A copied `elpa/` can carry stale `.elc` files.** Copying between machines rewrites mtimes, so
  Emacs may decide a `.elc` is older than its `.el` and silently load the slower source
  (`Source file ... newer than byte-compiled file`). Fix with `M-x package-recompile-all`.
- **No `:which-key`.** Deliberately not installed; shortcut data is bare `"key" command` pairs.
- **Not a git repo.** This folder is copied into a separate dotfiles repo by hand; since it is
  source-only, copying all of it is safe. Nothing here is backed up until that copy happens.

## Startup

~0.25s on Arch. Check with `M-x emacs-init-time`, or from a shell:

```sh
emacs -nw --eval '(progn (princ (emacs-init-time) #'\''external-debugging-output) (kill-emacs))'
```

(`message` here would print to the echo area and be wiped when Emacs restores the terminal.)

If it regresses, the usual suspects are an eager `require` in a module, or a stale quickstart file.
`config-dashboard` is the one deliberate eager `require` — the dashboard has to be built before the
first frame is shown, so it cannot be deferred.

## External deps

`basedpyright-langserver` and `jupyter` on `PATH` (per venv for jupyter), JetBrainsMono Nerd Font.

Org → PDF export (`C-c C-e l p`) needs a LaTeX engine. This config uses **tectonic** (`pacman -S
tectonic`, ~15 MiB, not the multi-GB TeX Live) via `my/latex-pdf-process` in `init.el`; it pulls
the packages a document needs on demand into `~/.cache`. Without it, export to `.tex` still works
but the PDF step fails. For code-block syntax highlighting via minted, add `-Z shell-escape` to
`my/latex-pdf-process` and set `org-latex-src-block-backend` to `minted`.
