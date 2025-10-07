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

-- Enhanced spell checking setup
local M = {}

function M.setup()
  -- Enable spell checking for specific file types
  local spell_filetypes = {
    "markdown",
    "text",
    "gitcommit",
    "latex",
    "rst",
    "org",
  }

  for _, ft in ipairs(spell_filetypes) do
    vim.api.nvim_create_autocmd("FileType", {
      pattern = ft,
      callback = function()
        vim.opt_local.spell = true
        vim.opt_local.spelllang = "en_us"
      end,
    })
  end

  -- Spell check key mappings
  local opts = { noremap = true, silent = true }

  -- Toggle spell check
  vim.keymap.set('n', '<leader>st', function()
    vim.opt_local.spell = not vim.opt_local.spell:get()
    local status = vim.opt_local.spell:get() and "enabled" or "disabled"
    vim.notify("Spell check " .. status)
  end, vim.tbl_extend('force', opts, { desc = "Toggle spell check" }))

  -- Navigate between misspelled words
  vim.keymap.set('n', ']s', ']s', vim.tbl_extend('force', opts, { desc = "Next misspelled word" }))
  vim.keymap.set('n', '[s', '[s', vim.tbl_extend('force', opts, { desc = "Previous misspelled word" }))

  -- Fix misspelled word
  vim.keymap.set('n', '<leader>sf', 'z=', vim.tbl_extend('force', opts, { desc = "Fix misspelled word" }))

  -- Add word to dictionary
  vim.keymap.set('n', '<leader>sa', 'zg', vim.tbl_extend('force', opts, { desc = "Add word to dictionary" }))

  -- Mark word as bad
  vim.keymap.set('n', '<leader>sb', 'zw', vim.tbl_extend('force', opts, { desc = "Mark word as bad" }))

  -- Undo add/bad word
  vim.keymap.set('n', '<leader>su', 'zug', vim.tbl_extend('force', opts, { desc = "Undo add word" }))

  -- Quick fix first suggestion
  vim.keymap.set('n', '<leader>sq', function()
    local word = vim.fn.expand('<cword>')
    local suggestions = vim.fn.spellsuggest(word, 1)
    if #suggestions > 0 then
      vim.cmd('normal! ciw' .. suggestions[1])
      vim.cmd('stopinsert')
    else
      vim.notify("No suggestions for: " .. word)
    end
  end, vim.tbl_extend('force', opts, { desc = "Quick fix with first suggestion" }))
end

-- Auto-setup
M.setup()

return M
