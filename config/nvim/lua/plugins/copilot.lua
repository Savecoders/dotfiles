-- GitHub Copilot inline suggestions and CopilotChat
return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
      suggestion = {
        enabled = true,
        auto_trigger = false,
        keymap = {
          accept = "<C-l>",
          accept_word = "<M-l>",
          accept_line = "<M-S-l>",
          next = "<M-]>",
          prev = "<M-[>",
          dismiss = "<C-]>",
        },
      },
      filetypes = {
        markdown = true,
        help = true,
      },
    },
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "main",
    dependencies = {
      { "zbirenbaum/copilot.lua" },
      { "nvim-lua/plenary.nvim" },
    },
    opts = {
      mappings = {
        reset = {
          insert = "<C-c>",
          normal = "<C-c>",
        },
      },
      prompts = {
        FixBuffer = {
          prompt = "Given these diagnostics in the file '$file' which is a '$language' file, please fix the issues: $diagnostics",
        },
      },
    },
    keys = {
      { "<leader>a", "<cmd>CopilotChat<CR>", mode = "n", desc = "Open Copilot Chat" },
      { "<leader>te", "<cmd>CopilotChatExplain<CR>", mode = "v", desc = "Explain Code" },
      { "<leader>tr", "<cmd>CopilotChatReview<CR>", mode = "v", desc = "Review Code" },
      { "<leader>tf", "<cmd>CopilotChatFix<CR>", mode = "v", desc = "Fix Code Issues" },
      { "<leader>to", "<cmd>CopilotChatOptimize<CR>", mode = "v", desc = "Optimize Code" },
      { "<leader>td", "<cmd>CopilotChatDocs<CR>", mode = "v", desc = "Generate Docs" },
      { "<leader>tt", "<cmd>CopilotChatTests<CR>", mode = "v", desc = "Generate Tests" },
      { "<leader>tm", "<cmd>CopilotChatCommit<CR>", mode = "n", desc = "Generate Commit Message" },
    },
  },
}
