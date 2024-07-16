return {
  -- add colorscheme
  { 'ellisonleao/gruvbox.nvim', lazy = true },
  { 'rebelot/kanagawa.nvim', lazy = true },
  { 'sainnhe/sonokai', lazy = true },
  { 'Mofiqul/dracula.nvim' },
  { 'datsfilipe/min-theme.nvim' },
  { 'catppuccin/nvim' },

  {
    'LazyVim/LazyVim',
    opts = {
      colorscheme = 'min-theme',
    },
    -- opts = function()
    --   -- load the colorscheme here
    --   vim.cmd([[colorscheme gruvbox]])
    --   vim.cmd('hi Normal guibg=NONE ctermbg=NONE')
    -- end,
  },
}
