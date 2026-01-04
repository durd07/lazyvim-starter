-- ~/.config/nvim/lua/plugins/robotframework.lua
local util = require("lspconfig.util")

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
      })
    end,
  },
}

