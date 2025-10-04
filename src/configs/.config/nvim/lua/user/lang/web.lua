-- Web development configuration (JavaScript, TypeScript, React, HTML, CSS)

-- Auto-commands for web development files
vim.api.nvim_create_augroup("WebDev", { clear = true })

-- JavaScript/TypeScript specific settings
vim.api.nvim_create_autocmd("FileType", {
  group = "WebDev",
  pattern = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
  callback = function()
    -- Use 2 spaces for indentation
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
    
    -- Enable spell checking for comments
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en_us"
    
    -- Set up some useful keymaps
    local opts = { noremap = true, silent = true, buffer = true }
    
    -- Quick console.log debugging
    vim.keymap.set("n", "<leader>cl", "oconsole.log();<Esc>hi", opts)
    vim.keymap.set("n", "<leader>cL", "Oconsole.log();<Esc>hi", opts)
    
    -- React component snippet
    vim.keymap.set("n", "<leader>rc", "iconst  = () => {<CR>return (<CR><CR>)<CR>}<CR><CR>export default <Esc>6kf i", opts)
  end,
})

-- HTML specific settings
vim.api.nvim_create_autocmd("FileType", {
  group = "WebDev",
  pattern = { "html", "htm" },
  callback = function()
    -- Use 2 spaces for indentation
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
    
    -- Enable spell checking
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en_us"
  end,
})

-- CSS specific settings
vim.api.nvim_create_autocmd("FileType", {
  group = "WebDev",
  pattern = { "css", "scss", "sass", "less" },
  callback = function()
    -- Use 2 spaces for indentation
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
  end,
})

-- JSON specific settings
vim.api.nvim_create_autocmd("FileType", {
  group = "WebDev",
  pattern = { "json", "jsonc" },
  callback = function()
    -- Use 2 spaces for indentation
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
    
    -- Conceallevel for better JSON viewing
    vim.opt_local.conceallevel = 0
  end,
})

-- Package.json specific keymaps
vim.api.nvim_create_autocmd("BufRead", {
  group = "WebDev",
  pattern = "package.json",
  callback = function()
    local opts = { noremap = true, silent = true, buffer = true }
    
    -- Quick npm commands
    vim.keymap.set("n", "<leader>ni", ":!npm install<CR>", opts)
    vim.keymap.set("n", "<leader>ns", ":!npm start<CR>", opts)
    vim.keymap.set("n", "<leader>nt", ":!npm test<CR>", opts)
    vim.keymap.set("n", "<leader>nb", ":!npm run build<CR>", opts)
  end,
})

-- Web development specific LSP settings
local function setup_web_lsp()
  -- These will be configured by the LSP plugin, but we can set some defaults here
  vim.api.nvim_create_autocmd("LspAttach", {
    group = "WebDev",
    pattern = { "*.js", "*.ts", "*.jsx", "*.tsx", "*.html", "*.css" },
    callback = function(event)
      local opts = { noremap = true, silent = true, buffer = event.buf }
      
      -- Web-specific LSP keymaps
      vim.keymap.set("n", "<leader>oi", ":OrganizeImports<CR>", opts)
      vim.keymap.set("n", "<leader>rf", ":Refactor<CR>", opts)
    end,
  })
end

setup_web_lsp()