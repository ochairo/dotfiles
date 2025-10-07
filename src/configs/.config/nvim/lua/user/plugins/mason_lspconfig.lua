-- mason-lspconfig.nvim - Mason integration with lspconfig
return {
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    opts = {
      ensure_installed = {
        "lua_ls",
        "ts_ls",
        "html",
        "cssls",
        "pyright",
        -- Remove problematic servers for now
        -- "tailwindcss", 
        -- "gopls",
        -- "rust_analyzer",
      },
      automatic_installation = true,
    },
  },
}