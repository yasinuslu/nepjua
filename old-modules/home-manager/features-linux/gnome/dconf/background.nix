# Generated via dconf2nix: https://github.com/gvolpe/dconf2nix
{ lib, ... }:

with lib.hm.gvariant;

{
  dconf.settings = {
    "org/gnome/desktop/background" = {
      color-shading-type = "solid";
      picture-options = "zoom";
      picture-uri = "file:///run/current-system/sw/share/backgrounds/gnome/geometrics-l.jxl";
      picture-uri-dark = "file:///run/current-system/sw/share/backgrounds/gnome/geometrics-d.jxl";
      primary-color = "#26a269";
      secondary-color = "#000000";
    };

  };
}
