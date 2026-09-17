-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Reload matugen colorscheme on Matugen dynamic theme update
vim.api.nvim_create_autocmd("Signal", {
  pattern = "SIGUSR1",
  callback = function()
    if vim.g.colors_name == "matugen" then
      vim.cmd("colorscheme matugen")
      if vim.g.transparent_enabled then
        pcall(function()
          require("transparent").clear()
        end)
      end
    end
  end,
  desc = "Reload Matugen theme on SIGUSR1 signal",
})

