-- Yazi file manager integration
return {
  "mikavilpas/yazi.nvim",
  event = "VeryLazy",
  keys = {
    { "sf", "<cmd>Yazi<cr>", desc = "Open Yazi at current file" },
    { "<leader>cw", "<cmd>Yazi cwd<cr>", desc = "Open Yazi in working directory" },
    { "<c-up>", "<cmd>Yazi toggle<cr>", desc = "Resume last Yazi session" },
  },
  opts = {
    open_for_directories = false,
    keymaps = { show_help = "<f1>" },
    yazi_floating_window_border = "rounded",
  },
}
