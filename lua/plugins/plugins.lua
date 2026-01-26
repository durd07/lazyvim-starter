return {
  -- Markdown Image Preview
  -- {
  --   "HakonHarnes/img-clip.nvim",
  --   event = "VeryLazy",
  --   opts = {
  --     -- add options here
  --     -- or leave it empty to use the default settings
  --   },
  --   keys = {
  --     -- suggested keymap
  --     { "<leader>p", "<cmd>PasteImage<cr>", desc = "Paste image from system clipboard" },
  --   },
  -- },
  -- {
  --   "folke/snacks.nvim",
  --   opts = {
  --     image = {
  --       enabled = true,
  --       markdown = {
  --         enabled = true,
  --         only_render_image_at_cursor = false,
  --       },
  --       -- Optional limits
  --       max_width = 80,
  --       max_height = 40,
  --       -- backend = "kitty", -- uncomment to force
  --     },
  --   },
  -- },
  {
    "mfussenegger/nvim-dap",
    keys = {
      {
        "<F9>",
        function()
          require("dap").toggle_breakpoint()
        end,
        desc = "Toggle Breakpoint",
      },
      {
        "<F5>",
        function()
          require("dap").continue()
        end,
        desc = "Run/Continue",
      },
      {
        "<F6>",
        function()
          require("dap").continue({ before = get_args })
        end,
        desc = "Run with Args",
      },
      {
        "<F11>",
        function()
          require("dap").step_into()
        end,
        desc = "Step Into",
      },
      {
        "<F23>", -- shift+F11
        function()
          require("dap").step_out()
        end,
        desc = "Step Out",
      },
      {
        "<F10>",
        function()
          require("dap").step_over()
        end,
        desc = "Step Over",
      },
    },
  },
  {
    "s1n7ax/nvim-window-picker",
    version = "2.*",
    config = function()
      require("window-picker").setup({
        hint = "floating-big-letter", -- Display hints with big floating letters
      })
    end,
  },
  {
    "akinsho/bufferline.nvim",
    opts = {
      options = {
        numbers = function(opts)
          return opts.id
        end,
      },
    },
  },
  {
    "loctvl842/monokai-pro.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      filter = "spectrum", -- classic | octagon | pro | machine | ristretto | spectrum

      override = function()
        local bg = "#0e0e0e"
        return {
          Normal = { bg = bg },
          NormalNC = { bg = bg },
        }
      end,
    },
  },
  {
    "dhananjaylatkar/cscope_maps.nvim",
    dependencies = {
      -- "nvim-telescope/telescope.nvim", -- optional [for picker="telescope"]
      "ibhagwan/fzf-lua", -- optional [for picker="fzf-lua"]
      -- "echasnovski/mini.pick", -- optional [for picker="mini-pick"]
      -- "folke/snacks.nvim", -- optional [for picker="snacks"]
    },
    opts = {
      -- USE EMPTY FOR DEFAULT OPTIONS
      -- DEFAULTS ARE LISTED BELOW
      --   -- maps related defaults
      disable_maps = false, -- "true" disables default keymaps
      skip_input_prompt = true, -- "true" doesn't ask for input
      prefix = "<C-\\>", -- prefix to trigger maps

      -- cscope related defaults
      cscope = {
        -- location of cscope db file
        db_file = "GTAGS", -- DB or table of DBs
        -- NOTE:
        --   when table of DBs is provided -
        --   first DB is "primary" and others are "secondary"
        --   primary DB is used for build and project_rooter
        -- cscope executable
        exec = "gtags-cscope", -- "cscope" or "gtags-cscope"
        -- choose your fav picker
        picker = "fzf-lua", -- "quickfix", "telescope", "fzf-lua" or "mini-pick"
        -- "true" does not open picker for single result, just JUMP
        skip_picker_for_single_result = true, -- "false" or "true"
        -- these args are directly passed to "cscope -f <db_file> <args>"
        db_build_cmd = { args = { "-bqkv" } },
        -- statusline indicator, default is cscope executable
        statusline_indicator = nil,
        -- try to locate db_file in parent dir(s)
        project_rooter = {
          enable = true, -- "true" or "false"
          -- change cwd to where db_file is located
          change_cwd = true, -- "true" or "false"
        },
      },

      -- stack view defaults
      stack_view = {
        tree_hl = true, -- toggle tree highlighting
      },
    },
  },
  {
    "ojroques/nvim-osc52",
    event = "VeryLazy",
    config = function()
      require("osc52").setup({
        max_length = 100000,
        silent = false,
        trim = false,
      })
    end,
  },
  {
    "danymat/neogen",
    dependencies = "nvim-treesitter/nvim-treesitter",
    config = function()
      require("neogen").setup({
        enabled = true,
        -- snippet_engine = "luasnip", -- works well with LazyVim default
      })
    end,
    keys = {
      {
        "<leader>cc",
        function()
          require("neogen").generate()
        end,
        desc = "Generate doc comment",
      },
    },
    -- Uncomment next line if you want to follow only stable versions
    -- version = "*"
  },
  {
    "github/copilot.vim",
    lazy = false, -- IMPORTANT: Copilot commands must be available immediately
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "monokai-pro",
    },
  },
}
