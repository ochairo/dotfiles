-- Neovim settings - optimized for performance and longevity
local opt = vim.opt
local g = vim.g

-- Leader key
g.mapleader = " "
g.maplocalleader = "\\"

-- Performance and responsiveness (ultra-fast mode)
opt.updatetime = 100  -- Even faster response (was 200)
opt.timeoutlen = 300  -- Even faster key mappings (was 400)
opt.lazyredraw = false -- Keep responsive
opt.synmaxcol = 150   -- Even more limited syntax highlighting (was 200)
opt.regexpengine = 1  -- Use old regex engine (often faster)
opt.redrawtime = 1500 -- Limit redraw time for large files

-- UI and appearance
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.wrap = false
opt.termguicolors = true
opt.pumheight = 10

-- Search and navigation
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = true

-- Editing behavior
opt.autoindent = true
opt.smartindent = true
opt.expandtab = true
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.shiftround = true

-- File handling
opt.backup = false
opt.writebackup = false
opt.swapfile = false
opt.undofile = true
opt.undolevels = 10000

-- Window and buffer behavior
opt.splitright = true
opt.splitbelow = true
opt.confirm = true
opt.hidden = true

-- Clipboard integration
opt.clipboard = "unnamedplus"

-- Modern defaults
opt.mouse = "a"
opt.scrolloff = 8
opt.sidescrolloff = 8

-- Disable unnecessary providers for faster startup
g.loaded_node_provider = 0
g.loaded_python3_provider = 0
g.loaded_perl_provider = 0
g.loaded_ruby_provider = 0
opt.completeopt = "menu,menuone,noselect"
opt.pumheight = 10

-- Performance
opt.updatetime = 300
opt.timeoutlen = 500

-- Folding
opt.foldmethod = "expr"
opt.foldexpr = "nvim_treesitter#foldexpr()"
opt.foldenable = false
