-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.diagnostic.enable(false) -- <leader>ud	Toggle Diagnostics

-- Disable LazyVim auto format
vim.g.autoformat = false

local opt = vim.opt
opt.relativenumber = false
opt.conceallevel = 0
opt.list = false -- Show some invisible characters (tabs...
opt.expandtab = false
opt.tabstop = 8
opt.shiftwidth = 8
opt.softtabstop = 0

vim.opt.list = true
vim.opt.listchars = {
    trail = '·', -- Shows trailing spaces as middle dots
    tab = '» ',  -- Shows tabs as '>>' followed by a space
    eol = '¶',   -- Shows end-of-line as a paragraph sign
    space = '·', -- Shows all spaces as middle dots (optional, can be noisy)
    extends = '>',
    precedes = '<'
}

opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldmethod = "expr"

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
