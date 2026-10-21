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

-- Neo-tree 的分隔线（NeoTreeWinSeparator）被主题填成了整格背景色，看起来像一条宽线。
-- 在主题加载 Neo-tree 高亮之后再覆盖它，使分隔格与正文背景一致。
local function fix_neo_tree_separator()
  local bg = vim.api.nvim_get_hl(0, { name = "Normal" }).bg
  bg = bg and string.format("#%06x", bg) or "#0e0e0e"
  vim.api.nvim_set_hl(0, "NeoTreeWinSeparator", { fg = bg, bg = bg })
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "neo-tree",
  callback = fix_neo_tree_separator,
})
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = fix_neo_tree_separator,
})

-- Document Symbols（Trouble）的背景色与 Neo-tree 保持一致
local function fix_trouble_background()
  local has_trouble = false
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype == "trouble" then
      has_trouble = true
      break
    end
  end
  if not has_trouble then
    return
  end

  local bg = vim.api.nvim_get_hl(0, { name = "NeoTreeNormal", link = false }).bg or 0x221f22
  for _, group in ipairs({ "TroubleNormal", "TroubleNormalNC" }) do
    local fg = vim.api.nvim_get_hl(0, { name = group, link = false }).fg
    vim.api.nvim_set_hl(0, group, { fg = fg, bg = bg })
  end

  -- 计数（Document Symbols 右上角的 10、文件名后的 10）不要单独底色
  local count_fg = vim.api.nvim_get_hl(0, { name = "TroubleCount", link = false }).fg
  vim.api.nvim_set_hl(0, "TroubleCount", { fg = count_fg, bg = bg })
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "trouble",
  callback = fix_trouble_background,
})
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = fix_trouble_background,
})

-- 隐藏 Document Symbols（Trouble）左侧那条竖分隔线。
-- 竖线属于它左边的窗口，所以只对"紧挨着 trouble 窗口左侧"的窗口通过 winhighlight 隐藏，
-- 其他普通 split 的分隔线保持不变。
local TROUBLE_SEP_HL = "TroubleSeparatorHidden"

local function update_trouble_separator()
  local bg = vim.api.nvim_get_hl(0, { name = "Normal", link = false }).bg
  bg = bg and string.format("#%06x", bg) or "#0e0e0e"
  vim.api.nvim_set_hl(0, TROUBLE_SEP_HL, { fg = bg, bg = bg })

  local wins = vim.api.nvim_tabpage_list_wins(0)
  local troubles = {}
  for _, win in ipairs(wins) do
    if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "trouble" then
      troubles[#troubles + 1] = win
    end
  end

  local pattern = "WinSeparator:" .. TROUBLE_SEP_HL
  for _, win in ipairs(wins) do
    if vim.api.nvim_win_get_config(win).relative == "" then
      local pos = vim.api.nvim_win_get_position(win)
      local width = vim.api.nvim_win_get_width(win)
      local height = vim.api.nvim_win_get_height(win)

      local adjacent = false
      for _, t in ipairs(troubles) do
        local tpos = vim.api.nvim_win_get_position(t)
        local theight = vim.api.nvim_win_get_height(t)
        -- trouble 的左边界正好是本窗口右边界 + 1 列分隔线，且上下有重叠
        if tpos[2] == pos[2] + width + 1 and tpos[1] < pos[1] + height and pos[1] < tpos[1] + theight then
          adjacent = true
          break
        end
      end

      local current = vim.wo[win].winhighlight
      local has = current:find(pattern, 1, true) ~= nil
      if adjacent and not has then
        vim.wo[win].winhighlight = (current ~= "" and current .. "," or "") .. pattern
      elseif not adjacent and has then
        vim.wo[win].winhighlight = (current:gsub(",?" .. pattern, ""))
      end
    end
  end
end

vim.api.nvim_create_autocmd(
  { "WinEnter", "WinNew", "WinClosed", "BufWinEnter", "BufWinLeave", "WinResized", "VimResized", "ColorScheme" },
  {
    pattern = "*",
    -- 延迟执行，确保 WinClosed 等事件触发时窗口列表已经更新
    callback = function()
      vim.schedule(update_trouble_separator)
    end,
  }
)

-- Activate otter.nvim automatically for certain filetypes
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "quarto", "org", "norg" },
  callback = function()
    require("otter").activate()
  end,
})
