return {
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
      colorscheme = "monokai-pro",
    },
  },
}
