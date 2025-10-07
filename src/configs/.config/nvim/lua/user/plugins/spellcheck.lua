-- Enhanced spell checking configuration
-- Combines Neovim's built-in spell check with improved UX

return {
  {
    "lewis6991/spellsitter.nvim",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require('spellsitter').setup({
        -- Enable for text-based files
        enable = {
          "markdown",
          "text",
          "gitcommit",
          "latex",
          "rst",
          "org",
        },
        -- Check comments and strings in code files
        captures = {
          "comment",
          "string",
        },
      })
    end
  },
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      defaults = {
        ["<leader>s"] = { name = "+spell" },
      },
    },
  },
}
