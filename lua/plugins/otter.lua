-- otter.nvim: LSP features for code blocks in markdown
return {
  {
    "jmbuhr/otter.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    ft = { "markdown" },
    config = function()
      local otter = require("otter")
      otter.setup({
        lsp = {
          -- Enable diagnostics in code blocks
          diagnostic_update_events = { "BufWritePost", "InsertLeave", "TextChanged" },
        },
        buffers = {
          -- Set filetype for otter buffers so LSP attaches
          set_filetype = true,
          -- Write otter buffers to disk (creates .otter.py files for debugging)
          write_to_disk = false,
        },
        handle_leading_whitespace = true,
      })
    end,
    keys = {
      {
        "<leader>oa",
        function()
          require("otter").activate({ "python", "lua", "bash", "javascript", "typescript", "go", "rust", "c", "cpp" })
          vim.notify("Otter activated", vim.log.levels.INFO)
        end,
        ft = "markdown",
        desc = "Otter Activate",
      },
      { "<leader>od", function() require("otter").deactivate() end, ft = "markdown", desc = "Otter Deactivate" },
      { "<leader>ok", function() require("otter").ask_hover() end, ft = "markdown", desc = "Otter Hover" },
      { "<leader>ogd", function() require("otter").ask_definition() end, ft = "markdown", desc = "Otter Go to Definition" },
    },
  },

  -- Add otter as a completion source for blink.cmp
  {
    "saghen/blink.cmp",
    optional = true,
    dependencies = {
      { "saghen/blink.compat", version = "*", opts = {} },
    },
    opts = {
      sources = {
        default = { "lsp", "path", "snippets", "buffer", "otter" },
        providers = {
          otter = {
            name = "otter",
            module = "blink.compat.source",
          },
        },
      },
    },
  },
}
