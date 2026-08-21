-- ~/.config/nvim/lua/plugins/lsp.lua
local util = require("lspconfig.util")

-- Standard project markers used to auto-detect the clangd root by walking
-- upward from the file. If your project has any of these at its top
-- level, no per-project configuration is needed.
-- NOTE: do NOT add CMakeLists.txt -- CMake projects have one in every
-- subdirectory and it would resolve to the file's local dir instead of
-- the actual project root.
local clangd_root_markers = {
  ".clangd", ".clang-tidy", ".clang-format",
  "compile_commands.json", "compile_flags.txt",
  "configure.ac", "Makefile", "configure.in", "config.h.in",
  "meson.build", "meson_options.txt", "build.ninja",
  ".git",
}

-- Paths we never want to start clangd for: scratch dirs, temp files, etc.
-- These are generic system paths and rarely belong to any project.
local clangd_skip_prefixes = {
  "/tmp/", "/var/tmp/", "/dev/", "/proc/", "/run/",
}

-- Pick the "best" running clangd to reuse for an external file. Preference
-- order:
--   (1) a clangd whose root is a prefix of the file (cheap sanity check),
--   (2) the clangd with the most attached buffers (i.e. the project the
--       user is actively working in),
--   (3) any running clangd, or nil if none are running.
local function pick_running_clangd(fname)
  local clangds = vim.lsp.get_clients({ name = "clangd" })
  if #clangds == 0 then return nil end
  local best, best_score = nil, -1
  for _, c in ipairs(clangds) do
    local root = c.config and c.config.root_dir
    if root then
      local score = vim.tbl_count(c.attached_buffers or {})
      if fname:sub(1, #root + 1) == root .. "/" then
        score = score + 100000  -- file is literally under this clangd's root
      end
      if score > best_score then best, best_score = c, score end
    end
  end
  return best
end

local function clangd_root_dir(bufnr, on_dir)
  local fname = vim.api.nvim_buf_get_name(bufnr)
  if fname == "" then return end

  -- 1) Detect the project root by walking upward for standard markers.
  --    Works for any project that has .clangd / .git / CMakeLists.txt /
  --    compile_commands.json / etc. at its top level -- no per-project
  --    configuration required.
  local matches = vim.fs.find(clangd_root_markers,
    { path = fname, upward = true, stop = "/" })
  if matches[1] then
    on_dir(vim.fs.dirname(matches[1]))
    return
  end

  -- 2) Skip scratch / runtime dirs entirely.
  for _, prefix in ipairs(clangd_skip_prefixes) do
    if fname:sub(1, #prefix) == prefix then return end
  end

  -- 3) External dependency (no project markers anywhere upward, e.g.
  --    /opt/LCP/..., /utas/..., /usr/include/..., vendor SDKs). If any
  --    clangd is already running, attach this buffer to it so the file
  --    resolves through the include graph of a TU clangd has parsed.
  local existing = pick_running_clangd(fname)
  if existing then
    on_dir(existing.config.root_dir)
    return
  end

  -- 4) Cold start with an external file and no clangd running -- skip
  --    attach. Once the user opens any project file, the project clangd
  --    starts, and the next external buffer (step 3) will reuse it.
end

return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.inlay_hints = { enabled = false }
      -- Merge in our custom settings for the Robot Framework LS
      opts.servers = vim.tbl_deep_extend("force", opts.servers or {}, {
        robotframework_ls = {
          -- *IMPORTANT*: 'settings.robot.variables' maps VAR_NAME → its value
          settings = {
            robot = {
              variables = {
                -- set ROOT to your project root (or any other path/value)
                ROOT = "/work/src/ntas/ft",
                -- you can add more if you like:
                -- DATA_DIR = "/absolute/path/to/data",
              },
            },
          },
        },
        -- Make clangd reuse a single instance per project, even when the
        -- buffer is an external file the project depends on (transitively
        -- included headers, vendor SDKs, /opt installs, /usr/include, etc.).
        -- Without this, nvim starts a separate single-file clangd for the
        -- external buffer, which has no compile_commands.json or .clangd
        -- config, so cross-file gd/hover fails inside the header.
        clangd = {
          root_dir = clangd_root_dir,
        },
      })
    end,
  },
}

