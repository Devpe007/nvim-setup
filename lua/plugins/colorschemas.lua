return {
  -- add colorscheme
  { 'ellisonleao/gruvbox.nvim', lazy = true },
  { 'rebelot/kanagawa.nvim', lazy = true },
  { 'sainnhe/sonokai', lazy = true },
  { 'dracula/vim', lazy = true },
  { 'catppuccin.nvim' },

  {
    'LazyVim/LazyVim',
    opts = {
      colorscheme = 'catppuccin',
    },
    -- opts = function()
    --   -- load the colorscheme here
    --   vim.cmd([[colorscheme gruvbox]])
    --   vim.cmd('hi Normal guibg=NONE ctermbg=NONE')
    -- end,
  },
}
