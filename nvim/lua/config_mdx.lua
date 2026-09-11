-- MDX: markdown + JSX
--
-- Parsing strategy: the `mdx` filetype is mapped to the stock `markdown`
-- tree-sitter parser rather than a dedicated mdx grammar.
--
-- Why not the dedicated grammar (srazzak/tree-sitter-mdx)? It has an open
-- external-scanner bug (upstream #10, also #8/#3): a paragraph followed by a
-- block-level JSX element mis-pairs the *next* fenced code block's delimiters
-- and the damage cascades to end of file, with NO error node to signal it.
-- Both of the most common docs shapes -- prose/<Note>/```code``` and a
-- self-closing <Note /> -- trigger it, so files silently lose all highlighting
-- below the first code block.
--
-- The markdown parser handles the same files cleanly and still injects
-- python/javascript/etc into fenced blocks. JSX blocks highlight as HTML via
-- markdown's html injection, which is accurate for reading. Revisit if
-- upstream #10 is fixed.
local M = {}

function M.set(params)
    params = params or {}

    -- 1. Filetype detection (nvim ships none for .mdx).
    vim.filetype.add({ extension = { mdx = "mdx" } })

    -- 2. Parse mdx buffers with the markdown grammar.
    vim.treesitter.language.register("markdown", "mdx")

    vim.api.nvim_create_autocmd("FileType", {
        pattern = "mdx",
        desc = "mdx: treesitter highlighting + markdown-style buffer opts",
        callback = function(ev)
            pcall(vim.treesitter.start, ev.buf, "markdown")
            vim.bo[ev.buf].commentstring = "<!-- %s -->"
            vim.bo[ev.buf].suffixesadd = ".mdx"
        end,
    })
end

return M
