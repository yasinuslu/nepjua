
{ inputs, lib, config, pkgs, colors, ... }: {
  imports = [
    ./fonts.nix
  ];

  home.packages = with pkgs; [
    # Gnome
    gnome.gnome-tweaks
    gnomeExtensions.advanced-alttab-window-switcher
    gnomeExtensions.quick-settings-tweaker
    gnomeExtensions.appindicator
  ];
}
