local M = {}
function M.set() 
    vim.opt.statusline = table.concat({
      "%#StAccent# [%n] ",   -- buffer number
      "%{%(&modified ? '%#StFileModified#' : '%#StFile#')%} %f %m ", -- filename block: purple when unsaved, theme color otherwise
      "%#StMid# %=",         -- stretch middle
      "%#StAccent# %l:%c ",  -- line:col, accent block
    })
end
return M
