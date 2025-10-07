-- Neovim init.lua - Main configuration entry point
-- Load user settings and core configuration
require("user.settings")
require("user.core")

-- Load plugins using lazy.nvim
require("user.plugins")

-- Load language-specific configurations
require("user.lang")