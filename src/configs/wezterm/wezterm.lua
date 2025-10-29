-- Minimal WezTerm config that preserves copy/paste functionality

local wezterm = require 'wezterm'
local config = {}

-- Detect OS (macOS and Linux only)
local is_macos = wezterm.target_triple:find("apple")
local is_linux = wezterm.target_triple:find("linux")

-- Theme and appearance
config.color_scheme = 'Tokyo Night'
config.font = wezterm.font('JetBrainsMono Nerd Font')
config.font_size = 16.0

-- Performance optimizations
config.check_for_updates = false
config.scrollback_lines = 500

-- OS-specific settings (macOS and Linux)
if is_macos or is_linux then
  -- Shared settings for macOS and Linux
  config.window_close_confirmation = "NeverPrompt"

  -- Shell integration for Unix-like systems - Launch Zellij with dev layout
  config.default_prog = { "/bin/zsh", "-c", "exec zellij -l dev" }

  -- Fullscreen on startup
  wezterm.on("gui-startup", function(cmd)
    local mux = wezterm.mux
    if mux then
      local tab, pane, window = mux.spawn_window(cmd or {})
      window:gui_window():toggle_fullscreen()
    end
  end)

  -- macOS-only settings
  if is_macos then
    config.native_macos_fullscreen_mode = true
  end
end

-- Tab bar
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true

return config
