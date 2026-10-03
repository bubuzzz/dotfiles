# Neovim Setup (new machine)

Config uses native `vim.pack`, native tree-sitter, and native LSP.
Parsers and LSP binaries are per-machine (not in git).

## 1. Tools (via mise)

```sh
mise install            # tree-sitter CLI, odin, elixir, etc.
mise use -g "github:DanielGavin/ols"   # Odin LSP
```

## 2. `ols` on PATH

mise installs it as `ols-arm64-darwin`. Symlink to `ols`:

```sh
# point straight at the real binary (NOT the mise shim)
ln -sf ~/.local/share/mise/installs/github-daniel-gavin-ols/*/ols-arm64-darwin ~/.local/bin/ols
ols --version           # verify
```

Ensure `~/.local/bin` is on PATH (and on the PATH nvim inherits).

## 3. Tree-sitter parsers (per machine)

Open nvim, then:

```
:TSInstall elixir heex eex python odin
```

Requires the `tree-sitter` CLI (installed in step 1).

## 4. Odin projects need `ols.json`

On Mac os, put an `ols.json` at each Odin project root pointing at the mise Odin collections (path has the version in it — update after Odin upgrades):

```json
{
  "collections": [
    { "name": "core",   "path": "~/.local/share/mise/installs/odin/<version>/core" },
    { "name": "vendor", "path": "~/.local/share/mise/installs/odin/<version>/vendor" }
  ],
  "enable_document_symbols": true,
  "enable_hover": true,
  "enable_snippets": true,
  "enable_semantic_tokens": true
}
```

## Notes

- Other LSPs (`basedpyright`, `elixirls`) must also be installed & on PATH.
- Completion is native (`<C-x><C-o>` or autotrigger). No completion plugin.
- ols needs a syntactically valid buffer to complete — errors kill suggestions.
