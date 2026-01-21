-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- Toggle bufferline + statusline with F12
local ui_visible = true

vim.keymap.set("n", "<F12>", function()
  ui_visible = not ui_visible

  -- statusline
  vim.o.laststatus = ui_visible and 3 or 0

  -- bufferline (tabline)
  vim.o.showtabline = ui_visible and 2 or 0
end, { desc = "Toggle bufferline and statusline" })
