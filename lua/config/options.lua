-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.diagnostic.enable(false) -- <leader>ud	Toggle Diagnostics
vim.opt.relativenumber = false
vim.opt.conceallevel = 0

vim.opt.shiftwidth = 8 -- Size of an indent
vim.opt.tabstop = 8 -- Number of spaces tabs count for

-- vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
-- vim.opt.foldmethod = "expr"

-- Disable LazyVim auto format
vim.g.autoformat = false
vim.opt.list = true
vim.opt.listchars = {
  space = "·",
  tab = " ->",
  eol = '¶',   -- Shows end-of-line as a paragraph sign
  trail = "·",
  nbsp = "°",
  extends = '>',
  precedes = '<'
}


local function copy(lines, _)
  require("osc52").copy(table.concat(lines, "\n"))
end

local function paste()
  return { vim.fn.split(vim.fn.getreg(""), "\n"), vim.fn.getregtype("") }
end

vim.g.clipboard = {
  name = "osc52",
  copy = { ["+"] = copy, ["*"] = copy },
  paste = { ["+"] = paste, ["*"] = paste },
}

-- loctvl842/monokai-pro.nvim doesn't set SnacksIndent, so indent lines has no color(has the same color with background), set it here
vim.api.nvim_set_hl(0, "SnacksIndent", { fg = "#3d3d3d", nocombine = true })
