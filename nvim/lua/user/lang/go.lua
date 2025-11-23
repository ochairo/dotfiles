-- Go Language Configuration
local keymap = vim.keymap.set

-- Go-specific keymaps
keymap("n", "<leader>gr", function()
  -- Run Go file
  vim.cmd("!go run %")
end, { desc = "Run Go file" })

keymap("n", "<leader>gb", function()
  -- Build Go project
  vim.cmd("!go build")
end, { desc = "Build Go project" })

keymap("n", "<leader>gt", function()
  -- Run Go tests
  vim.cmd("!go test ./...")
end, { desc = "Run Go tests" })

keymap("n", "<leader>gm", function()
  -- Run Go mod tidy
  vim.cmd("!go mod tidy")
end, { desc = "Go mod tidy" })

keymap("n", "<leader>gf", function()
  -- Format Go code
  vim.cmd("!gofmt -w %")
end, { desc = "Format Go code" })

keymap("n", "<leader>ge", function()
  -- Insert Go error handling template
  local template = [[
if err != nil {
    return err
}]]
  vim.api.nvim_put(vim.split(template, "\n"), "l", true, true)
end, { desc = "Insert Go error handling" })

keymap("n", "<leader>gs", function()
  -- Insert Go struct template
  local struct_name = vim.fn.input("Struct name: ")
  if struct_name ~= "" then
    local template = string.format([[
type %s struct {
    // Add fields here
}]], struct_name)
    vim.api.nvim_put(vim.split(template, "\n"), "l", true, true)
  end
end, { desc = "Insert Go struct template" })

-- Auto-commands for Go
local go_group = vim.api.nvim_create_augroup("GoDevelopment", { clear = true })

-- Set Go-specific options
vim.api.nvim_create_autocmd("FileType", {
  group = go_group,
  pattern = "go",
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = false -- Go uses tabs
    vim.opt_local.textwidth = 100
    vim.opt_local.colorcolumn = "100"
  end,
})

-- Auto-format Go files on save
vim.api.nvim_create_autocmd("BufWritePre", {
  group = go_group,
  pattern = "*.go",
  callback = function()
    require("conform").format({ async = false, lsp_fallback = true })
  end,
})

-- Organize imports on save
vim.api.nvim_create_autocmd("BufWritePre", {
  group = go_group,
  pattern = "*.go",
  callback = function()
    local params = vim.lsp.util.make_range_params()
    params.context = { only = { "source.organizeImports" } }
    local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 1000)
    for _, res in pairs(result or {}) do
      for _, r in pairs(res.result or {}) do
        if r.edit then
          vim.lsp.util.apply_workspace_edit(r.edit, "UTF-8")
        end
      end
    end
  end,
})