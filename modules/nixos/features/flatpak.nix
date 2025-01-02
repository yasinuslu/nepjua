{pkgs, ...}: {
  # Enable Flatpak service
  services.flatpak.enable = true;

  # Add required packages
  environment.systemPackages = with pkgs; [
    flatpak
    gnome-software
  ];

  # Configure XDG portal for better Flatpak integration
  xdg.portal = {
    enable = true;
    extraPortals = [pkgs.xdg-desktop-portal-gtk];
    # Set GTK portal as default
    config.common.default = "gtk";
  };

  # Add Flathub repository after installation
  system.activationScripts.flatpak-init = ''
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  '';
}
