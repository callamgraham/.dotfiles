-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- Spawn the nushell as the default
config.default_prog = { '/usr/bin/nu' }

-- For example, changing the color scheme:
config.color_scheme = 'Gruvbox Dark'

-- and finally, return the configuration to wezterm
return config
