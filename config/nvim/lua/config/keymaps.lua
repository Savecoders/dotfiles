-- Set leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Keymap helper
local set = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Restart Neovim
set("n", "<leader>rr", "<cmd>restart<CR>", opts)

-- Disable the spacebar key's default behavior in Normal and Visual modes
set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- Split window
set("n", "ss", ":split<Return>", opts)
set("n", "sv", ":vsplit<Return>", opts)
set("n", "sx", "<cmd>close<CR>", opts)

-- Make current file executable
set("n", "<leader>X", "<cmd>!chmod +x %<CR>", { silent = true, desc = "Make current file executable" })

-- Select all
set("n", "<C-a>", "gg<S-v>G", { desc = "Select all" })

-- Jumping (line start / end)
set({ "n", "o", "x" }, "<s-h>", "^", { desc = "Jump to beginning of line" })
set({ "n", "o", "x" }, "<s-l>", "g_", { desc = "Jump to end of line" })

-- Copy file paths
set("n", "<leader>cf", '<cmd>let @+ = expand("%")<CR>', { desc = "Copy File Name" })

-- File explorer (nvim-tree)
set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
set("n", "<leader>fe", ":NvimTreeFindFileToggle<CR>", { desc = "Find current file in explorer" })

-- Yazi terminal file manager
set("n", "sf", "<cmd>Yazi<cr>", { desc = "Open Yazi at current file" })
set("n", "<leader>cw", "<cmd>Yazi cwd<cr>", { desc = "Open Yazi in working directory" })

-- Center the screen after scrolling up/down with Ctrl-u/d
set("n", "<C-u>", "<C-u>zz")
set("n", "<C-d>", "<C-d>zz")
set("n", "n", "nzzzv", opts)
set("n", "N", "Nzzzv", opts)

-- Stay in indent mode
set("v", "<", "<gv", opts)
set("v", ">", ">gv", opts)

-- Toggle line wrapping
set("n", "<leader>lw", "<cmd>set wrap!<CR>", opts)

-- Save file
set({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })
set("n", "<leader>w", "<cmd>w<cr>", { desc = "Save file" })

-- Clear search highlights
set({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and clear search highlight" })
set("n", "<leader>nh", "<cmd>nohl<cr>", { desc = "Clear search highlights" })

-- Quit all
set("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })

-- Increment / decrement numbers
set("n", "<leader>+", "<C-a>", { desc = "Increment number" })
set("n", "<leader>-", "<C-x>", { desc = "Decrement number" })

-- Window management
set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })

-- Tab management
set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" })
set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" })
set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" })
set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" })

-- Move blocks of text up/down with K/J in visual mode
set("v", "K", ":m '<-2<CR>gv=gv", { silent = true, desc = "Move block up" })
set("v", "J", ":m '>+1<CR>gv=gv", { silent = true, desc = "Move block down" })

-- Delete single character without copying into register
set("n", "x", '"_x', opts)

-- Search and replace the word under cursor in the file
set(
  "n",
  "<leader>sr",
  [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
  { desc = "Search & replace word under cursor" }
)

-- Lazygit
set("n", "<leader>gg", ":LazyGit<CR>", opts)

-- Delete without yanking
set({ "n", "v" }, "<leader>d", [["_d]])

-- Paste in visual mode without yanking replaced text
set("x", "p", [["_dP]])

-- Resize window
set("n", "<leader><left>", ":vertical resize +20<cr>", opts)
set("n", "<leader><right>", ":vertical resize -20<cr>", opts)
set("n", "<leader><up>", ":resize +10<cr>", opts)
set("n", "<leader><down>", ":resize -10<cr>", opts)

-- Buffers
set("n", "<Tab>", ":bnext<cr>", opts)
set("n", "<S-Tab>", ":bprevious<cr>", opts)
set("n", "<leader>bd", ":bdelete!<cr>", opts)
set("n", "<leader>bn", "<cmd>enew<cr>", opts)

-- Lazy and Mason
set("n", "<leader>ll", "<cmd>Lazy<CR>", { desc = "Open Lazy plugin manager" })
set("n", "<leader>lm", "<cmd>Mason<CR>", { desc = "Open Mason LSP installer" })

-- Toggle autoformat on save
set("n", "<leader>tf", ":ToggleAutoformat<CR>", { desc = "Toggle format on save" })

-- Markdown render
set("n", "<leader>pt", "<cmd>RenderMarkdown toggle<CR>", { desc = "Toggle Markdown Render" })

-- Transparent toggle
set("n", "<leader>tt", "<cmd>TransparentToggle<CR>", { desc = "Toggle transparent background" })
