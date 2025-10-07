-- GitHub Copilot - Simple setup with basic completion and chat
return {
  -- Modern Copilot completion
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        suggestion = {
          enabled = true,
          auto_trigger = true,
          keymap = {
            accept = "<C-j>",
            next = "<C-l>",
            prev = "<C-h>",
            dismiss = "<C-e>",
          },
        },
        panel = { enabled = false },
        filetypes = {
          yaml = true,
          markdown = true,
          help = false,
          gitcommit = false,
          gitrebase = false,
          hgcommit = false,
          svn = false,
          cvs = false,
          ["."] = false,
        },
      })
    end,
  },
  
  -- Basic chat interface
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "zbirenbaum/copilot.lua" },
      { "nvim-lua/plenary.nvim" },
    },
    build = "make tiktoken",
    keys = {
      -- Essential chat commands only
      { "<leader>cc", ":CopilotChat ", desc = "Copilot Chat" },
      { "<leader>ce", "<cmd>CopilotChatExplain<cr>", desc = "Explain", mode = { "n", "v" } },
      { "<leader>cr", "<cmd>CopilotChatReview<cr>", desc = "Review", mode = { "n", "v" } },
      { "<leader>cf", "<cmd>CopilotChatFix<cr>", desc = "Fix", mode = { "n", "v" } },
      { "<leader>cv", "<cmd>CopilotChatToggle<cr>", desc = "Toggle Chat" },
    },
    config = function()
      require("CopilotChat").setup({
        debug = false,
        window = {
          layout = 'vertical',
          width = 0.4,
        },
      })
    end,
  },
}