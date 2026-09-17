-- Extensible UI for Neovim notifications and LSP progress
return {
  "j-hui/fidget.nvim",
  event = "LspAttach",
  opts = {
    notification = {
      window = {
        winblend = 0,
        normal_hl = "FloatBorder",
      },
    },
  },
}
