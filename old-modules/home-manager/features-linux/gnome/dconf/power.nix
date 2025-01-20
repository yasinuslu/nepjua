# Generated via dconf2nix: https://github.com/gvolpe/dconf2nix
{ lib, ... }:

with lib.hm.gvariant;

{
  dconf.settings = {
    "org/gnome/settings-daemon/plugins/power" = {
      power-button-action = "hibernate";
      sleep-inactive-ac-type = "nothing";
    };

  };
}
