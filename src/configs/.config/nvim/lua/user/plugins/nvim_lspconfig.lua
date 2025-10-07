-- nvim-lspconfig.lua - LSP Configuration
return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      { "antosha417/nvim-lsp-file-operations", config = true },
    },
    config = function()
      local core_lsp = require("user.core.lsp")
      core_lsp.setup()

      local keymap = vim.keymap.set
      keymap("n", "<leader>ck", "<cmd>LspInfo<cr>", { desc = "Lsp Info" })

      local on_attach = core_lsp.on_attach
      local capabilities = require("cmp_nvim_lsp").default_capabilities(core_lsp.capabilities())

      -- Diagnostic signs
      local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
      end

      -- Use modern vim.lsp.config for server setup
      local servers = {
        html = {},
        cssls = {},
        pyright = {},
        -- Remove problematic servers for now
        -- tailwindcss = {},
        -- rust_analyzer = {},
        -- gopls = {},
        -- Updated: ts_ls instead of deprecated tsserver
        ts_ls = {
          settings = {
            typescript = {
              inlayHints = {
                includeInlayParameterNameHints = "literal",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = false,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
            },
            javascript = {
              inlayHints = {
                includeInlayParameterNameHints = "all",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
            },
          },
        },
        lua_ls = {
          settings = {
            Lua = {
              runtime = { version = "LuaJIT" },
              workspace = {
                checkThirdParty = false,
                library = {
                  [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                  [vim.fn.stdpath("config") .. "/lua"] = true,
                },
              },
              completion = { callSnippet = "Replace" },
            },
          },
        },
      }

      -- Setup servers using modern approach
      for server, config in pairs(servers) do
        config.on_attach = on_attach
        config.capabilities = capabilities
        
        -- Use vim.lsp.config for Neovim 0.11+
        if vim.lsp.config then
          vim.lsp.config[server] = config
        else
          -- Fallback to lspconfig for older versions
          require("lspconfig")[server].setup(config)
        end
      end
    end,
  },
}