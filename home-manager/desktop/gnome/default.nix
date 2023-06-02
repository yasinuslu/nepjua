
{ inputs, lib, config, pkgs, colors, ... }: {
  imports = [
    ./fonts.dconf.nix
    ./extensions.dconf.nix
    ./keybindings.dconf.nix
    ./mutter.dconf.nix
    ./nautilus.dconf.nix
  ];

  home.packages = with pkgs; [
    # Gnome
    gnome.gnome-tweaks
    gnomeExtensions.advanced-alttab-window-switcher
    gnomeExtensions.quick-settings-tweaker
    gnomeExtensions.appindicator
  ];
}
