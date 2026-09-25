return {
  { "ellisonleao/gruvbox.nvim", lazy = true, opts = { transparent_mode = false } },
  { "rose-pine/neovim", lazy = true, opts = {} },
  { "vague-theme/vague.nvim", lazy = true, opts = { transparent = false } },

  {
    "sainnhe/gruvbox-material",
    lazy = true,
    config = function()
      vim.g.gruvbox_material_enable_italic = true
      vim.g.gruvbox_material_background = "hard"
      vim.g.gruvbox_material_transparent_background = 0
    end,
  },

  {
    "rebelot/kanagawa.nvim",
    lazy = true,
    opts = {
      keywordStyle = { italic = false },
      colors = {
        theme = {
          all = {
            ui = { bg_gutter = "none" },
          },
        },
      },
      overrides = function(colors)
        local theme = colors.theme
        return {
          ["@keyword.coroutine"] = { fg = theme.syn.special, bold = true },
          ["@keyword.function"] = { fg = theme.syn.fun, bold = true },
        }
      end,
    },
  },

  -- toggle transparency with <leader>tt
  {
    "xiyaowong/transparent.nvim",
    lazy = false,
    opts = {
      extra_groups = {
        "NvimTreeNormal",
        "NvimTreeNormalNC",
        "NvimTreeSignColumn",
        "NvimTreeEndOfBuffer",
        "NvimTreeWinSeparator",
        "NormalFloat",
        "FloatBorder",
      },
    },
  },

  -- load default colorscheme
  {
    dir = vim.fn.stdpath("config") .. "/colors",
    name = "matugen-colorscheme",
    lazy = false,
    priority = 1000,
    config = function()
      pcall(vim.cmd.colorscheme, "matugen")
    end,
  },
}
