return {
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
    "Kurama622/markdown-org",
    ft = "markdown",
    config = function()
      vim.g.language_path = {
        python = "/usr/bin/python3",
        python3 = "/usr/bin/python3",
        go = "go",
        c = "gcc -Wall",
        cpp = "g++ -std=c++11 -Wall",
        bash = "bash",
        ["c++"] = "g++ -std=c++11 -Wall",
      }
      return {
        default_quick_keys = 0,
        vim.api.nvim_set_var("org#style#border", 2),
        vim.api.nvim_set_var("org#style#bordercolor", "FloatBorder"),
        vim.api.nvim_set_var("org#style#color", "String"),
      }
    end,
    keys = {
      { "<leader>mr", "<cmd>call org#main#runCodeBlock()<cr>" },
      { "<leader>ml", "<cmd>call org#main#runLanguage()<cr>" },
    },
  },
  -- {
  --   "durd07/code-runner",
  --   -- name = "code_runner",
  --   config = function()
  --     require("code-runner").setup()
  --   end,
  --   ft = { "markdown" }, -- load it only for markdown files
  -- },
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
    config = function()
      require("monokai-pro").setup()
    end,
  },
  -- {
  --   "powerman/vim-plugin-AnsiEsc",
  --   config = function()
  --     vim.cmd("autocmd BufReadPost * :AnsiEsc")
  --   end,
  -- },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "monokai-pro-spectrum",
    },
  },
  -- {
  --   "toppair/peek.nvim",
  --   event = { "VeryLazy" },
  --   build = "deno task --quiet build:fast",
  --   config = function()
  --     require("peek").setup()
  --     vim.api.nvim_create_user_command("PeekOpen", require("peek").open, {})
  --     vim.api.nvim_create_user_command("PeekClose", require("peek").close, {})
  --   end,
  -- },
  -- {
  --   "iamcco/markdown-preview.nvim",
  --   keys = { { "<f7>", "<cmd> MarkdownPreviewToggle <CR>" } },
  --   cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  --   ft = "markdown",
  --   build = "cd app && npm install",
  --   config = function()
  --     vim.api.nvim_exec2(
  --       [[
  --       function MkdpBrowserFn(url)
  --         execute 'silent ! kitty @ launch --dont-take-focus --bias 40 awrit ' . a:url
  --       endfunction
  --     ]],
  --       {}
  --     )
  --
  --     vim.g.mkdp_theme = "dark"
  --     vim.g.mkdp_filetypes = { "markdown" }
  --     vim.g.mkdp_browserfunc = "MkdpBrowserFn"
  --   end,
  -- },
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
}
