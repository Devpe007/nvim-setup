-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- Set transparent background
-- local function augroup(name)
--   return vim.api.nvim_create_augroup('lazyvim_' .. name, { clear = true })
-- end
--
-- vim.api.nvim_create_autocmd({ 'VimEnter' }, {
--   group = augroup('vimenter'),
--   callback = function()
--     vim.cmd('hi Normal guibg=NONE ctermbg=NONE')
--   end,
-- })
--
-- Adicione isso no seu init.lua ou em um arquivo de configuração apropriado
vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  pattern = { '*.erb', '*.eruby' },
  callback = function()
    vim.bo.filetype = 'html'
  end,
})
