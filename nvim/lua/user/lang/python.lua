-- Python Language Configuration
local keymap = vim.keymap.set

-- Python-specific keymaps
keymap("n", "<leader>pr", function()
  -- Run Python file
  vim.cmd("!python3 %")
end, { desc = "Run Python file" })

keymap("n", "<leader>pi", function()
  -- Start Python REPL
  vim.cmd("terminal python3")
end, { desc = "Start Python REPL" })

keymap("n", "<leader>pp", function()
  -- Insert Python print statement
  local word = vim.fn.expand("<cword>")
  local line = string.format('print(f"%s: {%s}")', word, word)
  vim.api.nvim_put({ line }, "l", true, true)
end, { desc = "Insert Python print for word under cursor" })

keymap("n", "<leader>pd", function()
  -- Insert Python docstring template
  local template = [[
"""
Brief description of the function.

Args:
    param1: Description of param1
    param2: Description of param2

Returns:
    Description of return value

Raises:
    ExceptionType: Description of when this exception is raised
"""]]
  vim.api.nvim_put(vim.split(template, "\n"), "l", true, true)
end, { desc = "Insert Python docstring template" })

-- Auto-commands for Python
local python_group = vim.api.nvim_create_augroup("PythonDevelopment", { clear = true })

-- Set Python-specific options
vim.api.nvim_create_autocmd("FileType", {
  group = python_group,
  pattern = "python",
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = true
    vim.opt_local.textwidth = 88
    vim.opt_local.colorcolumn = "88"
  end,
})

-- Auto-format Python files on save
vim.api.nvim_create_autocmd("BufWritePre", {
  group = python_group,
  pattern = "*.py",
  callback = function()
    require("conform").format({ async = false, lsp_fallback = true })
  end,
})