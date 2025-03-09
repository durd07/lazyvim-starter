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
    "powerman/vim-plugin-AnsiEsc",
    config = function()
      vim.cmd("autocmd BufReadPost * :AnsiEsc")
    end,
  },
}
