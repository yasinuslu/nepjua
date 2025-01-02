{pkgs, ...}: {
  # Enable Flatpak service
  services.flatpak.enable = true;

  # Add required packages
  environment.systemPackages = with pkgs; [
    flatpak
    gnome-software # Now at top-level
    gnome-software-plugin-flatpak
  ];

  # Add Flathub repository after installation
  system.activationScripts.flatpak-init = ''
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  '';

  # Configure XDG portal for better Flatpak integration
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
  };
}
