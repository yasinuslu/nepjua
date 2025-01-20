{ pkgs, ... }:
{
  # Enable AppImage support
  programs.appimage = {
    enable = true;
    # Enable binfmt support for AppImages
    binfmt = true;
    # Configure extra packages for compatibility
    package = pkgs.appimage-run.override {
      extraPkgs =
        pkgs: with pkgs; [
          # GTK-related
          gtk3
          gtk4
          gdk-pixbuf
          pango
          cairo
          atk
          at-spi2-core
          at-spi2-atk
          dbus
          librsvg

          # Common runtime dependencies
          glib
          libsoup_2_4
          webkitgtk_4_1
          json-glib

          # System libraries
          zlib
          glibc
          libGL

          # SELinux and security
          libselinux
          libsepol

          # Additional dependencies
          xorg.libX11
          xorg.libXrandr
          xorg.libXi
          xorg.libXcursor
          xorg.libXdamage
          xorg.libXrender
          xorg.libXfixes
          xorg.libXcomposite
          xorg.libXext
          xorg.libXtst
          xorg.libXScrnSaver
          xorg.libxkbfile
          xorg.libxshmfence

          # Audio/Video
          libpulseaudio
          libvorbis
          ffmpeg
          alsa-lib
          pipewire

          # For Flutter apps
          libglvnd
          vulkan-loader
          mesa
          mesa.drivers

          # For better integration
          shared-mime-info
          hicolor-icon-theme
          gsettings-desktop-schemas
          adwaita-icon-theme

          # Wayland support
          wayland
          libxkbcommon

          # Additional runtime libraries
          libdrm
          libnotify
          libappindicator
          libdbusmenu
          nss
          nspr
          expat
          cups
          libunwind
        ];
    };
  };

  # Configure system for AppImage execution
  boot.supportedFilesystems.fuse = true;

  # Required system packages
  environment.systemPackages = with pkgs; [
    fuse
    xdg-utils # For better desktop integration
  ];

  # Enable D-Bus and other required services
  services.dbus.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
  };
}
