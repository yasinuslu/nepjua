{pkgs, ...}: {
  # Enable graphical interface
  services.xserver.enable = true;

  services.xserver.displayManager.gdm.enable = true;
  # Enable Wayland support
  services.xserver.displayManager.gdm.wayland = false;

  services.xserver.desktopManager.gnome.enable = true;

  services.gnome = {
    # Enable remote desktop and keyring
    gnome-remote-desktop.enable = true;
    gnome-keyring.enable = true;
    gnome-settings-daemon.enable = true;
    at-spi2-core.enable = true;
  };

  # Enable X11 apps on Wayland
  programs.xwayland.enable = false;

  xdg = {
    portal = {
      enable = true;
      wlr.enable = true;
      extraPortals = [pkgs.xdg-desktop-portal-gtk pkgs.xdg-desktop-portal-wlr];
    };
  };

  environment.systemPackages = with pkgs; [
    # Wayland utilities
    wl-clipboard
    xdg-desktop-portal
    xdg-desktop-portal-gtk
    wev

    # GNOME core apps
    gnome-shell
    # gnome-extension-manager
    gnome-terminal
  ];

  # Enable inter-process communication
  services.dbus.enable = true;

  # Configure input methods
  i18n.inputMethod = {
    enable = true;
    type = "ibus";
    ibus.engines = with pkgs.ibus-engines; [
      libpinyin
    ];
  };
}
