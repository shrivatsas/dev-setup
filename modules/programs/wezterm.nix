{ config, pkgs, lib, ... }:
{
  programs.wezterm = {
    enable = true;
    extraConfig = ''
      local wezterm = require 'wezterm'

      local function scheme_for_appearance(appearance)
        if appearance:find('Dark') then
          return 'Solarized (dark)'
        else
          return 'Solarized (light)'
        end
      end

      -- Runtime toggle between Solarized Light/Dark
      wezterm.on('toggle-theme', function(window, _)
        local overrides = window:get_config_overrides() or {}
        if overrides.color_scheme == 'Solarized (light)' then
          overrides.color_scheme = 'Solarized (dark)'
        else
          overrides.color_scheme = 'Solarized (light)'
        end
        window:set_config_overrides(overrides)
      end)

      return {
        font = wezterm.font_with_fallback({
          'JetBrainsMono Nerd Font',
          'Symbols Nerd Font Mono',
          'Noto Color Emoji',
        }),
        font_size = 13.0,
        color_scheme = scheme_for_appearance(wezterm.gui and wezterm.gui.get_appearance() or 'Dark'),
        hide_tab_bar_if_only_one_tab = true,
        use_fancy_tab_bar = false,
        -- Toggle theme with Ctrl+Shift+D
        keys = {
          { key = 'D', mods = 'CTRL|SHIFT', action = wezterm.action.EmitEvent('toggle-theme') },
        },
      }
    '';
  };
}
