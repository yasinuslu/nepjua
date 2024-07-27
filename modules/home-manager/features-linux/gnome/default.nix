{pkgs, ...}: {
  imports = [
    ./dconf.nix
    ./theme.nix
  ];

  home.packages = with pkgs; [
    # Gnome
    gnome-tweaks
    gnomeExtensions.advanced-alttab-window-switcher
    gnomeExtensions.quick-settings-tweaker
    gnomeExtensions.appindicator
    dconf-editor
  ];
}
