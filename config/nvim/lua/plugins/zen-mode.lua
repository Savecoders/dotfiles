-- Distraction-free coding mode
return {
  "folke/zen-mode.nvim",
  cmd = "ZenMode",
  keys = {
    { "<leader>z", "<cmd>ZenMode<cr>", desc = "Toggle Zen Mode" },
  },
  opts = {
    plugins = {
      options = {
        laststatus = 0,
      },
      tmux = true,
      kitty = { enabled = true, font = "+2" },
    },
  },
}
