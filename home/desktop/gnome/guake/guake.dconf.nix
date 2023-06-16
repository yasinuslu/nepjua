# Generated via dconf2nix: https://github.com/gvolpe/dconf2nix
{ lib, ... }:

with lib.hm.gvariant;

{
  dconf.settings = {
    "apps/guake/general" = {
      compat-delete = "delete-sequence";
      display-n = 0;
      display-tab-names = 0;
      gtk-use-system-default-theme = true;
      hide-tabs-if-one-tab = false;
      history-size = 1000;
      load-guake-yml = true;
      max-tab-name-length = 100;
      mouse-display = true;
      open-tab-cwd = true;
      prompt-on-quit = true;
      quick-open-command-line = "gedit %(file_path)s";
      restore-tabs-notify = true;
      restore-tabs-startup = true;
      save-tabs-when-changed = true;
      schema-version = "3.9.0";
      scroll-keystroke = true;
      use-default-font = true;
      use-popup = true;
      use-scrollbar = true;
      use-trayicon = true;
      window-halignment = 0;
      window-height = 50;
      window-losefocus = false;
      window-refocus = false;
      window-tabbar = true;
      window-width = 100;
    };

    "apps/guake/keybindings/global" = {
      show-hide = "<Primary>grave";
    };

    "apps/guake/style/background" = {
      transparency = 89;
    };

    "apps/guake/style/font" = {
      allow-bold = true;
      palette = "#222222222222:#FFFF00000F0F:#8C8CE0E00A0A:#FFFFB9B90000:#00008D8DF8F8:#6C6C4343A5A5:#0000D7D7EBEB:#FFFFFFFFFFFF:#444444444444:#FFFF27273F3F:#ABABE0E05A5A:#FFFFD1D14141:#00009292FFFF:#9A9A5F5FEBEB:#6767FFFFEFEF:#FFFFFFFFFFFF:#FFFFFAFAF3F3:#0D0D0F0F1818";
      palette-name = "Argonaut";
      style = "Monospace 11";
    };

  };
}
