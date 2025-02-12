# Generated via dconf2nix: https://github.com/gvolpe/dconf2nix
{ lib, ... }:

with lib.hm.gvariant;

{
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      cursor-theme = "Adwaita";
      document-font-name = "Cantarell 11";
      font-antialiasing = "grayscale";
      font-hinting = "slight";
      font-name = "Cantarell 11";
      gtk-theme = "Adwaita";
      icon-theme = "Adwaita";
      monospace-font-name = "JetBrainsMono Nerd Font Mono 11";
      text-scaling-factor = 1.2;
    };

  };
}
