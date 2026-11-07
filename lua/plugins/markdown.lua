# render-markdown: renders markdown buffers (also used by opencode.nvim output)
return {
{
  'MeanderingProgrammer/render-markdown.nvim',
  opts = {
    anti_conceal = { enabled = false },
    file_types = { 'markdown', 'opencode_output' },
    -- remove the full-line background on markdown headings; keep icon/text colors
    heading = { backgrounds = {} },
  },
  ft = { 'markdown', 'opencode_output' },
  -- render-markdown links RenderMarkdownH<n> -> @markup.heading.<n>.markdown
  -- with default=true at load, but a colorscheme loaded afterwards clears
  -- those links and its reload() only restores generated colors, not the
  -- base ones. Without them the heading extmarks replace the treesitter
  -- colors and every level renders in the same (Normal) color.
  config = function(_, opts)
    require('render-markdown').setup(opts)
    -- monokai-pro defines every markdown heading level as the same yellow,
    -- and the previous per-level distinction came only from the (now
    -- removed) background tints. Give each level its own foreground from
    -- the monokai-pro palette instead.
    local heading_fg = {
      '#ff6188', -- H1 red
      '#a9dc76', -- H2 green
      '#ffd866', -- H3 yellow
      '#fc9867', -- H4 orange
      '#78dce8', -- H5 cyan
      '#ab9df9', -- H6 purple
    }
    local function apply()
      for i, fg in ipairs(heading_fg) do
        vim.api.nvim_set_hl(0, ('RenderMarkdownH%d'):format(i), { fg = fg, bold = true })
        vim.api.nvim_set_hl(0, ('@markup.heading.%d.markdown'):format(i), { fg = fg })
      end
    end
    apply()
    vim.api.nvim_create_autocmd('ColorScheme', {
      group = vim.api.nvim_create_augroup('render-markdown-heading-fg', { clear = true }),
      callback = apply,
    })
  end,
}
}
