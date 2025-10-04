-- Ultra-minimal working Wezterm configuration

local wezterm = require 'wezterm'
local config = {}

-- Basic settings
config.font = wezterm.font('JetBrainsMono Nerd Font')
config.font_size = 14
config.color_scheme = 'Tokyo Night'

-- Disable non-essential features
config.check_for_updates = false
config.automatically_reload_config = false
config.enable_tab_bar = false
config.window_decorations = "RESIZE"
config.window_padding = { left = 4, right = 4, top = 4, bottom = 4 }

-- Performance settings
config.scrollback_lines = 500
config.animation_fps = 1
config.cursor_blink_rate = 0

-- Shell configuration (create fresh sessions each time)
config.default_prog = {
  "/bin/zsh",
  "-c",
  "export FAST_TERMINAL=1; exec zellij -l dev"
}

-- macOS settings
config.native_macos_fullscreen_mode = true
config.window_close_confirmation = "NeverPrompt"

-- Restore dedicated desktop functionality
wezterm.on("gui-startup", function(cmd)
  local mux = wezterm.mux
  if mux then
    local tab, pane, window = mux.spawn_window(cmd or {})
    -- Enter native fullscreen immediately for dedicated desktop
    window:gui_window():toggle_fullscreen()
  end
end)

return config
