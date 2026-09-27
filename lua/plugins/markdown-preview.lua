-- Render markdown-preview.nvim inside a terminal-browser split instead of an
-- external browser. mkdp_browser is unusable here: its opener treats WSL as
-- Windows and launches the browser through `cmd.exe /c start`, which cannot see
-- the Linux-side terminal-browser, and it cannot pass --split either.
--
-- mkdp_combine_preview keeps a single page that follows whichever markdown
-- buffer is current, so there is only ever one browser pane to track.

local split = "right"
local size = "0.5"

-- read once from the main loop: the async callbacks below run in fast events
local in_tmux = vim.env.TMUX ~= nil
local editor_pane = vim.env.TMUX_PANE

---@type { bufnr?: integer, key?: string, pane?: string, pid?: integer, closed?: boolean }|nil
local preview = nil

local function terminate(entry, wait)
  local cmd
  if entry.pane and in_tmux then
    cmd = { "tmux", "kill-pane", "-t", entry.pane }
  elseif entry.pid then
    cmd = { "kill", tostring(entry.pid) }
  else
    return
  end
  local proc = vim.system(cmd)
  if wait then
    proc:wait(2000)
  end
end

local function close(wait)
  local entry = preview
  if not entry then
    return
  end
  preview = nil
  -- when the browser is still starting up, terminate() runs once it reports back
  entry.closed = true
  terminate(entry, wait)
end

-- `terminal-browser open` returns the browser key but not the pane it landed in
local function locate_pane(entry)
  vim.system({ "terminal-browser", "ls", "--json" }, { text = true }, function(out)
    local ok, data = pcall(vim.json.decode, out.stdout or "")
    if ok then
      for _, browser in ipairs(data.browsers or {}) do
        if browser.key == entry.key then
          entry.pane = browser.pane and browser.pane.pane
          entry.pid = browser.pid
          break
        end
      end
    end
    if entry.closed then
      terminate(entry)
    end
  end)
end

local function open(url)
  close()

  local entry = { bufnr = tonumber(url:match("/page/(%d+)")) or vim.api.nvim_get_current_buf() }
  preview = entry

  -- "/" for find and vim keys come from terminal-browser config, see
  -- ~/.config/terminal-browser/shortcuts.json (find) and ctrl+m (vim mode).
  local cmd = { "terminal-browser", "open", url, "--split", split, "--size", size }

  vim.system(cmd, { text = true }, function(out)
    if out.code ~= 0 then
      if preview == entry then
        preview = nil
      end
      vim.schedule(function()
        local err = vim.trim((out.stderr or "") .. (out.stdout or ""))
        vim.notify("terminal-browser failed: " .. err, vim.log.levels.ERROR)
      end)
      return
    end
    -- the new pane takes the terminal focus, hand it back to the editor
    if in_tmux and editor_pane then
      vim.system({ "tmux", "select-pane", "-t", editor_pane })
    end
    local ok, info = pcall(vim.json.decode, out.stdout or "")
    entry.key = ok and info and info.key or nil
    if entry.key then
      locate_pane(entry)
    end
  end)
end

local function toggle()
  if preview then
    pcall(vim.cmd, "MarkdownPreviewStop")
    close()
  else
    vim.cmd("MarkdownPreview")
  end
end

return {
  "iamcco/markdown-preview.nvim",
  keys = {
    { "<leader>cp", toggle, ft = "markdown", desc = "Markdown Preview (terminal-browser)" },
  },
  init = function()
    _G.MkdpOpenInTerminalBrowser = open
    vim.cmd([[
      function! MkdpTerminalBrowserOpen(url) abort
        call v:lua.MkdpOpenInTerminalBrowser(a:url)
      endfunction
    ]])
    vim.g.mkdp_browserfunc = "MkdpTerminalBrowserOpen"
    vim.g.mkdp_theme = "dark"
    -- the pane is torn down by toggle() and the autocmds below, so mkdp must not
    -- stop the preview on its own when leaving the markdown buffer
    vim.g.mkdp_auto_close = 0
    -- reuse the open page for the markdown buffer you switch to
    vim.g.mkdp_combine_preview = 1
    vim.g.mkdp_combine_preview_auto_refresh = 1

    local group = vim.api.nvim_create_augroup("mkdp_terminal_browser", { clear = true })
    vim.api.nvim_create_autocmd("BufEnter", {
      group = group,
      callback = function(ev)
        if preview and vim.bo[ev.buf].filetype == "markdown" then
          preview.bufnr = ev.buf
        end
      end,
    })
    vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
      group = group,
      callback = function(ev)
        if preview and preview.bufnr == ev.buf then
          close()
        end
      end,
    })
    vim.api.nvim_create_autocmd("VimLeavePre", {
      group = group,
      callback = function()
        close(true)
      end,
    })
  end,
}
