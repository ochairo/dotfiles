-- Rust Language Configuration
local keymap = vim.keymap.set

-- Rust-specific keymaps
keymap("n", "<leader>rr", function()
  -- Run Rust file
  vim.cmd("!cargo run")
end, { desc = "Cargo run" })

keymap("n", "<leader>rb", function()
  -- Build Rust project
  vim.cmd("!cargo build")
end, { desc = "Cargo build" })

keymap("n", "<leader>rt", function()
  -- Run Rust tests
  vim.cmd("!cargo test")
end, { desc = "Cargo test" })

keymap("n", "<leader>rc", function()
  -- Check Rust code
  vim.cmd("!cargo check")
end, { desc = "Cargo check" })

keymap("n", "<leader>rf", function()
  -- Format Rust code
  vim.cmd("!cargo fmt")
end, { desc = "Cargo format" })

keymap("n", "<leader>rl", function()
  -- Run Clippy
  vim.cmd("!cargo clippy")
end, { desc = "Cargo clippy" })

keymap("n", "<leader>rd", function()
  -- Generate Rust docs
  vim.cmd("!cargo doc --open")
end, { desc = "Cargo docs" })

keymap("n", "<leader>rp", function()
  -- Insert Rust print statement
  local word = vim.fn.expand("<cword>")
  local line = string.format('println!("%s: {:?}", %s);', word, word)
  vim.api.nvim_put({ line }, "l", true, true)
end, { desc = "Insert Rust println for word under cursor" })

keymap("n", "<leader>rm", function()
  -- Insert Rust match template
  local template = [[
match value {
    Ok(result) => result,
    Err(err) => return Err(err),
}]]
  vim.api.nvim_put(vim.split(template, "\n"), "l", true, true)
end, { desc = "Insert Rust match template" })

keymap("n", "<leader>rs", function()
  -- Insert Rust struct template
  local struct_name = vim.fn.input("Struct name: ")
  if struct_name ~= "" then
    local template = string.format([[
#[derive(Debug, Clone)]
pub struct %s {
    // Add fields here
}

impl %s {
    pub fn new() -> Self {
        Self {
            // Initialize fields
        }
    }
}]], struct_name, struct_name)
    vim.api.nvim_put(vim.split(template, "\n"), "l", true, true)
  end
end, { desc = "Insert Rust struct template" })

-- Auto-commands for Rust
local rust_group = vim.api.nvim_create_augroup("RustDevelopment", { clear = true })

-- Set Rust-specific options
vim.api.nvim_create_autocmd("FileType", {
  group = rust_group,
  pattern = "rust",
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = true
    vim.opt_local.textwidth = 100
    vim.opt_local.colorcolumn = "100"
  end,
})

-- Auto-format Rust files on save
vim.api.nvim_create_autocmd("BufWritePre", {
  group = rust_group,
  pattern = "*.rs",
  callback = function()
    require("conform").format({ async = false, lsp_fallback = true })
  end,
})