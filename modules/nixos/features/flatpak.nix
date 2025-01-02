{pkgs, ...}: {
  # Enable Flatpak service
  services.flatpak.enable = true;

  # Add required packages
  environment.systemPackages = with pkgs; [
    flatpak
    gnome-software
    # GTK runtime dependencies
    gtk3
    gtk4
    gdk-pixbuf
    shared-mime-info
  ];

  # Configure XDG portal for better Flatpak integration
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-gnome
    ];
    # Set GTK portal as default
    config.common.default = "gtk";
    # Configure GTK portal
    config.gtk = {
      default = ["gtk"];
      "org.freedesktop.impl.portal.Secret" = ["gnome-keyring"];
    };
  };

  # Add Flathub repository using a systemd service
  systemd.services.flatpak-init = {
    description = "Add Flathub repository to Flatpak";
    wantedBy = ["multi-user.target"];
    path = [pkgs.flatpak];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };
}
