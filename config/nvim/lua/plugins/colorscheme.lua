return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    opts = {
      transparent_background = true,
      flavour = "mocha",
    },
    integrations = {
      cmp = true,
      gitsigns = true,
      nvimtree = true,
      treesitter = true,
      notify = false,
      mini = {
        enabled = true,
        indentscope_color = "",
      },
    },
  },
  {
    "sainnhe/sonokai",
    name = "sonokai",
    priority = 1000,
    lazy = false,
    config = function()
      vim.g.sonokai_transparent_background = "1"
      vim.g.sonokai_enable_italic = "1"
      vim.g.sonokai_style = "andromeda"
    end,
  },
  {
    "miikanissi/modus-themes.nvim",
    name = "modus",
    priority = 1000,
  },
  { "rose-pine/neovim", name = "rose-pine" },
  { "nyoom-engineering/oxocarbon.nvim", name = "oxocarbon" },
  { "rktjmp/lush.nvim", dependencies = { "mcchrish/zenbones.nvim" } },
  {
    "scottmckendry/cyberdream.nvim",
    lazy = false,
    priority = 1000,
  },
  { "NTBBloodbath/doom-one.nvim", name = "doom-one" },
  { "AhmedAbdulrahman/aylin.vim", name = "aylin" },
  {
    "xiyaowong/transparent.nvim",
  },
  {
    "ribru17/bamboo.nvim",
    lazy = false,
  },
  {
    "dgox16/oldworld.nvim",
    lazy = false,
    priority = 1000,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      -- change this line to change the color scheme
      colorscheme = "catppuccin",
    },
  },
}
