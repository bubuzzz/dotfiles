local M = {}
function M.set() 
    vim.opt.statusline = table.concat({
      "%#StAccent# [%n] ",   -- buffer number
      "%#StFile# %f %m ",    -- filename + modified flag
      "%#StMid# %=",         -- stretch middle
      "%#StAccent# %l:%c ",  -- line:col, accent block
    })
end
return M
