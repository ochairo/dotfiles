-- Plugin management with lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load essential plugin modules - each plugin in its own file
require("lazy").setup({
  -- Core functionality
  { import = "user.plugins.plenary" },
  { import = "user.plugins.nvim_tree" },
  { import = "user.plugins.nvim_bqf" },
  { import = "user.plugins.comment" },
  { import = "user.plugins.nvim_autopairs" },

  -- UI
  { import = "user.plugins.tokyonight" },
  { import = "user.plugins.lualine" },
  { import = "user.plugins.nvim_web_devicons" },

  -- LSP and completion
  { import = "user.plugins.nvim_lspconfig" },
  { import = "user.plugins.mason" },
  { import = "user.plugins.mason_lspconfig" },
  { import = "user.plugins.nvim_cmp" },

  -- Language features
  { import = "user.plugins.nvim_treesitter" },
  { import = "user.plugins.nvim_telescope" },
  { import = "user.plugins.gitlog" },

  -- AI assistance
  { import = "user.plugins.copilot" },

  -- Spell checking
  { import = "user.plugins.spellcheck" },
}, {
  -- Optimized lazy.nvim configuration for fast startup
  defaults = {
    lazy = true,  -- Enable lazy loading by default
    version = false,
  },
  install = { colorscheme = { "tokyonight" } },
  checker = { enabled = false }, -- Disable automatic updates for stability
  change_detection = { notify = false },
  performance = {
    cache = {
      enabled = true,
    },
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

-- Load additional modules that aren't lazy.nvim plugins
require('user.plugins.gitstatus')
require('user.plugins.terminal')
