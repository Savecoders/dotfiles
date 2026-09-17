-- OKLCH color picker and live color highlight
return {
  "eero-lehtinen/oklch-color-picker.nvim",
  event = "VeryLazy",
  keys = {
    {
      "<leader>co",
      function()
        require("oklch-color-picker").open_picker()
      end,
      desc = "Open Color Picker",
    },
    {
      "<leader>cu",
      function()
        require("oklch-color-picker").pick_under_cursor()
      end,
      desc = "Pick Color Under Cursor",
    },
  },
  opts = {
    highlight_colors = {
      enable = true,
    },
    keymaps = {
      confirm = "<CR>",
    },
  },
}
