
{ inputs, lib, config, pkgs, colors, ... }: {
  home.packages = with pkgs; [
    # Gnome
    gnome.gnome-tweaks
    guake
    gnomeExtensions.advanced-alttab-window-switcher
    gnomeExtensions.quick-settings-tweaker
    gnomeExtensions.appindicator
  ]
}
