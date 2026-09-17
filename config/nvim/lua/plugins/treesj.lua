-- Split/join code blocks with Tree-sitter
return {
  "Wansmer/treesj",
  keys = {
    {
      "<leader>m",
      function()
        require("treesj").toggle()
      end,
      desc = "Toggle split/join code block",
    },
  },
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  opts = {
    max_join_length = 200,
    use_default_keymaps = false,
  },
}
