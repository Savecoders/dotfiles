return {
  {
    "mason-org/mason.nvim",
    opts = {
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    },
  },
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
      "saghen/blink.cmp",
    },
    config = function()
      local capabilities = require("blink.cmp").get_lsp_capabilities()
      local mason_lspconfig = require("mason-lspconfig")

      mason_lspconfig.setup({
        ensure_installed = {
          -- TS Stack
          "ts_ls",
          "html",
          "cssls",
          "tailwindcss",
          "eslint",
          "astro",
          "emmet_ls",
          "jsonls",
          "graphql",
          "prismals",

          -- Go
          "gopls",
          "golangci_lint_ls",

          -- Lua
          "lua_ls",

          -- Python
          "pyright",

          -- Misc
          "dockerls",
          "docker_compose_language_service",
          "yamlls",
          "taplo",
          "bashls",
        },
        automatic_installation = true,
        handlers = {
          function(server_name)
            require("lspconfig")[server_name].setup({
              capabilities = capabilities,
            })
          end,
          ["omnisharp"] = function()
            require("lspconfig").omnisharp.setup({
              capabilities = capabilities,
              handlers = {
                ["textDocument/definition"] = function(...)
                  local ok, extended = pcall(require, "omnisharp_extended")
                  if ok then
                    return extended.handler(...)
                  end
                end,
              },
              enable_roslyn_analyzers = true,
              organize_imports_on_format = true,
              enable_import_completion = true,
            })
          end,
          ["lua_ls"] = function()
            require("lspconfig").lua_ls.setup({
              capabilities = capabilities,
              settings = {
                Lua = {
                  diagnostics = { globals = { "vim" } },
                  workspace = { checkThirdParty = false },
                  telemetry = { enable = false },
                },
              },
            })
          end,
        },
      })
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      ensure_installed = {
        "prettier",
        "prettierd",
        "stylua",
        "isort",
        "black",
        "gofumpt",
        "goimports",
        "rustfmt",
        "eslint_d",
        "pylint",
        "golangci-lint",
        "hadolint",
        "shellcheck",
      },
    },
    dependencies = {
      "mason-org/mason.nvim",
    },
  },
}
