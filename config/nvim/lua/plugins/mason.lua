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
    opts = {
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
        "gopls", -- official Go LSP
        "golangci_lint_ls", -- Go linter LSP

        -- Lua
        "lua_ls",

        -- Python
        "pyright",

        -- Misc
        "dockerls", -- Dockerfile
        "docker_compose_language_service",
        "yamlls", -- YAML (k8s, CI configs)
        "taplo", -- TOML
        "bashls", -- Shell scripts
      },
    },
    dependencies = {
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
      "neovim/nvim-lspconfig",
    },
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      ensure_installed = {
        "prettier", -- JS/TS/CSS/HTML/JSON/Astro
        "prettierd", -- faster prettier daemon
        "stylua", -- Lua
        "isort", -- Python imports
        "black", -- Python
        "gofumpt", -- Go (stricter gofmt)
        "goimports", -- Go imports organizer
        "rustfmt", -- Rust

        -- Linters
        "eslint_d", -- JS/TS fast linter
        "pylint", -- Python
        "golangci-lint", -- Go linter suite
        "hadolint", -- Dockerfile linter
        "shellcheck", -- Bash linter
      },
    },
    dependencies = {
      "mason-org/mason.nvim",
    },
  },
}
