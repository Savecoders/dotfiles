-- ================================================================================================
-- TITLE : auto-commands
-- ABOUT : automatically run code on defined events (e.g. save, yank, lsp attach)
-- ================================================================================================

-- Restore last cursor position when reopening a file
local last_cursor_group = vim.api.nvim_create_augroup("LastCursorGroup", {})
vim.api.nvim_create_autocmd("BufReadPost", {
  group = last_cursor_group,
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Highlight the yanked text for 200ms
local highlight_yank_group = vim.api.nvim_create_augroup("HighlightYank", {})
vim.api.nvim_create_autocmd("TextYankPost", {
  group = highlight_yank_group,
  pattern = "*",
  callback = function()
    vim.hl.on_yank({
      higroup = "IncSearch",
      timeout = 200,
    })
  end,
})

-- Toggle autoformat command
vim.g.autoformat_enabled = true -- Global toggle for autoformatting (default: enabled)
vim.api.nvim_create_user_command("ToggleAutoformat", function()
  vim.g.autoformat_enabled = not vim.g.autoformat_enabled
  if vim.g.autoformat_enabled then
    vim.notify("Autoformat enabled", vim.log.levels.INFO)
  else
    vim.notify("Autoformat disabled", vim.log.levels.WARN)
  end
end, {})

-- Auto-save on focus lost or buffer leave
local autosave_group = vim.api.nvim_create_augroup("AutoSaveGroup", {})
vim.api.nvim_create_autocmd({ "FocusLost", "BufLeave" }, {
  group = autosave_group,
  pattern = "*",
  callback = function()
    if vim.bo.modified and vim.bo.buftype == "" and vim.fn.expand("%") ~= "" then
      vim.cmd("silent! write")
    end
  end,
  desc = "Auto-save modified files on focus lost or buffer leave",
})

-- Reload matugen colorscheme on Matugen dynamic theme update
vim.api.nvim_create_autocmd("Signal", {
  pattern = "SIGUSR1",
  callback = function()
    if vim.g.colors_name == "matugen" then
      vim.cmd("colorscheme matugen")
      if vim.g.transparent_enabled then
        pcall(function()
          require("transparent").clear()
        end)
      end
    end
  end,
  desc = "Reload Matugen theme on SIGUSR1 signal",
})

-- LSP Attach keymaps and diagnostics
local lsp_mappings_group = vim.api.nvim_create_augroup("LspMappings", {})
vim.api.nvim_create_autocmd("LspAttach", {
  group = lsp_mappings_group,
  callback = function(ev)
    local bufnr = ev.buf
    local keymap = vim.keymap.set
    local opts = { noremap = true, silent = true, buffer = bufnr }

    -- LSP navigation & actions
    opts.desc = "Go to definition"
    keymap("n", "gd", vim.lsp.buf.definition, opts)

    opts.desc = "Go to declaration"
    keymap("n", "gD", vim.lsp.buf.declaration, opts)

    opts.desc = "Show LSP references"
    keymap("n", "gR", "<cmd>FzfLua lsp_references<CR>", opts)

    opts.desc = "Show LSP implementations"
    keymap("n", "gi", "<cmd>FzfLua lsp_implementations<CR>", opts)

    opts.desc = "Show LSP type definitions"
    keymap("n", "gt", "<cmd>FzfLua lsp_typedefs<CR>", opts)

    opts.desc = "See available code actions"
    keymap({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)

    opts.desc = "Smart rename"
    keymap("n", "<leader>rn", vim.lsp.buf.rename, opts)

    opts.desc = "Show document diagnostics"
    keymap("n", "<leader>D", "<cmd>FzfLua diagnostics_document<CR>", opts)

    opts.desc = "Show line diagnostics"
    keymap("n", "<leader>d", vim.diagnostic.open_float, opts)

    opts.desc = "Previous diagnostic"
    keymap("n", "[d", function()
      vim.diagnostic.jump({ count = -1, float = true })
    end, opts)

    opts.desc = "Next diagnostic"
    keymap("n", "]d", function()
      vim.diagnostic.jump({ count = 1, float = true })
    end, opts)

    opts.desc = "Show hover documentation"
    keymap("n", "K", vim.lsp.buf.hover, opts)

    opts.desc = "Restart LSP"
    keymap("n", "<leader>rs", ":LspRestart<CR>", opts)
  end,
})

-- Diagnostic icons
local severity = vim.diagnostic.severity
vim.diagnostic.config({
  signs = {
    text = {
      [severity.ERROR] = " ",
      [severity.WARN] = " ",
      [severity.HINT] = "󰠠 ",
      [severity.INFO] = " ",
    },
  },
})
