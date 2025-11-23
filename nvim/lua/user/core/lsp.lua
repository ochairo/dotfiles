-- Core LSP configuration
local M = {}

-- LSP keymaps that will be attached when LSP client attaches
M.on_attach = function(client, bufnr)
  local opts = { buffer = bufnr, silent = true }
  local keymap = vim.keymap.set

  -- LSP actions
  keymap("n", "gR", "<cmd>Telescope lsp_references<CR>", opts)
  keymap("n", "gD", vim.lsp.buf.declaration, opts)
  keymap("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)
  keymap("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)
  keymap("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts)
  keymap("n", "<leader>ca", vim.lsp.buf.code_action, opts)
  keymap("n", "<leader>rn", vim.lsp.buf.rename, opts)
  keymap("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)
  keymap("n", "<leader>d", vim.diagnostic.open_float, opts)
  keymap("n", "[d", vim.diagnostic.goto_prev, opts)
  keymap("n", "]d", vim.diagnostic.goto_next, opts)
  keymap("n", "K", vim.lsp.buf.hover, opts)
  keymap("n", "<leader>rs", ":LspRestart<CR>", opts)
  
  -- Workspace folders
  keymap("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts)
  keymap("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts)
  keymap("n", "<leader>wl", function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, opts)
end

-- Common LSP capabilities
M.capabilities = function()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  capabilities.textDocument.completion.completionItem.resolveSupport = {
    properties = { "documentation", "detail", "additionalTextEdits" }
  }
  return capabilities
end

-- Diagnostic configuration
M.setup_diagnostics = function()
  local signs = {
    Error = " ",
    Warn = " ",
    Hint = " ",
    Info = " "
  }
  
  for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
  end

  vim.diagnostic.config({
    virtual_text = {
      spacing = 4,
      source = "if_many",
      prefix = "●",
    },
    signs = true,
    update_in_insert = false,
    underline = true,
    severity_sort = true,
    float = {
      focusable = false,
      style = "minimal",
      border = "rounded",
      source = "always",
      header = "",
      prefix = "",
    },
  })
end

-- Setup function to be called from LSP plugin
M.setup = function()
  M.setup_diagnostics()
end

return M