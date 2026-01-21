-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- show line number for telescope preview
vim.cmd("autocmd User TelescopePreviewerLoaded setlocal number")

-- Activate otter.nvim automatically for certain filetypes
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "quarto", "org", "norg" },
  callback = function()
    require("otter").activate()
  end,
})
