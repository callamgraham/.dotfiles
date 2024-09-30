-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- Spawn the nushell as the default
config.default_prog = { '/usr/bin/nu' }

-- For example, changing the color scheme:
config.color_scheme = 'Gruvbox Dark (Gogh)'

-- use wayland
config.enable_wayland = true

config.keys = {
  -- Send "CTRL-A" to the terminal when pressing CTRL-A, CTRL-A
  {key="F1", mods="", action=wezterm.action{ActivateTab=0}},
  {key="F2", mods="", action=wezterm.action{ActivateTab=1}},
  {key="F3", mods="", action=wezterm.action{ActivateTab=2}},
  {key="F4", mods="", action=wezterm.action{ActivateTab=3}},
  {key="F5", mods="", action=wezterm.action{ActivateTab=4}},
 }
-- and finally, return the configuration to wezterm
return config
