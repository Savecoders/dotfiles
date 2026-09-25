-- Floating cmdline, search, and message UI
return {
  "folke/noice.nvim",
  event = "VeryLazy",
  dependencies = {
    "MunifTanjim/nui.nvim",
  },
  opts = {
    lsp = {
      signature = {
        enabled = false,
      },
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
      },
    },
    routes = {
      {
        filter = {
          event = "msg_show",
          any = {
            { find = "%d+L, %d+B" },
            { find = "; after #%d+" },
            { find = "; before #%d+" },
          },
        },
        view = "mini",
      },
      {
        filter = {
          event = "notify",
          find = "textDocument/signatureHelp",
        },
        opts = { skip = true },
      },
      {
        filter = {
          event = "msg_show",
          find = "textDocument/signatureHelp",
        },
        opts = { skip = true },
      },
    },
    presets = {
      bottom_search = false, -- use floating search in center
      command_palette = false, -- position cmdline in the middle of the screen
      long_message_to_split = true,
      inc_rename = false,
      lsp_doc_border = true,
    },
    views = {
      cmdline_popup = {
        position = {
          row = "40%",
          col = "50%",
        },
        size = {
          min_width = 60,
          width = "auto",
          height = "auto",
        },
      },
    },
  },
}
