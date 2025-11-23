-- Language info and file type configurations
local M = {}

-- File type associations
M.setup_filetypes = function()
  vim.filetype.add({
    extension = {
      conf = "conf",
      env = "dotenv",
      tiltfile = "python",
      tf = "terraform",
      tfvars = "terraform",
    },
    filename = {
      [".env"] = "dotenv",
      ["tsconfig.json"] = "jsonc",
      [".eslintrc.json"] = "jsonc",
    },
    pattern = {
      ["%.env%.[%w_.-]+"] = "dotenv",
    },
  })
end

-- Auto commands for file types
M.setup_autocmds = function()
  local augroup = vim.api.nvim_create_augroup("FileTypeSettings", { clear = true })
  
  -- Remove trailing whitespace on save
  vim.api.nvim_create_autocmd("BufWritePre", {
    group = augroup,
    pattern = "*",
    callback = function()
      local save_cursor = vim.fn.getpos(".")
      pcall(function() vim.cmd [[%s/\s\+$//e]] end)
      vim.fn.setpos(".", save_cursor)
    end,
  })
  
  -- Highlight on yank
  vim.api.nvim_create_autocmd("TextYankPost", {
    group = augroup,
    callback = function()
      vim.highlight.on_yank()
    end,
  })
  
  -- Resize splits when window is resized
  vim.api.nvim_create_autocmd("VimResized", {
    group = augroup,
    callback = function()
      vim.cmd("tabdo wincmd =")
    end,
  })
  
  -- Go to last location when opening a buffer
  vim.api.nvim_create_autocmd("BufReadPost", {
    group = augroup,
    callback = function()
      local mark = vim.api.nvim_buf_get_mark(0, '"')
      local lcount = vim.api.nvim_buf_line_count(0)
      if mark[1] > 0 and mark[1] <= lcount then
        pcall(vim.api.nvim_win_set_cursor, 0, mark)
      end
    end,
  })
  
  -- Close some filetypes with <q>
  vim.api.nvim_create_autocmd("FileType", {
    group = augroup,
    pattern = {
      "PlenaryTestPopup",
      "help",
      "lspinfo",
      "man",
      "notify",
      "qf",
      "spectre_panel",
      "startuptime",
      "tsplayground",
      "neotest-output",
      "checkhealth",
      "neotest-summary",
      "neotest-output-panel",
    },
    callback = function(event)
      vim.bo[event.buf].buflisted = false
      vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
    end,
  })
  
  -- Wrap and check for spell in text filetypes
  vim.api.nvim_create_autocmd("FileType", {
    group = augroup,
    pattern = { "gitcommit", "markdown" },
    callback = function()
      vim.opt_local.wrap = true
      vim.opt_local.spell = true
    end,
  })
end

-- Setup function
M.setup = function()
  M.setup_filetypes()
  M.setup_autocmds()
end

return M