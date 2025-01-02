{pkgs, ...}: {
  # Enable AppImage support
  programs.appimage = {
    enable = true;
    # Enable binfmt support for AppImages
    binfmt = true;
    # Configure extra packages for compatibility
    package = pkgs.appimage-run.override {
      extraPkgs = pkgs:
        with pkgs; [
          # GTK-related
          gtk3
          gtk4
          gdk-pixbuf
          pango
          cairo

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

          # Audio/Video
          libpulseaudio
          libvorbis
          ffmpeg

          # For Flutter apps
          libglvnd
          vulkan-loader

          # For better integration
          shared-mime-info
          hicolor-icon-theme
        ];
    };
  };

  # Configure system for AppImage execution
  boot.supportedFilesystems.fuse = true;

  # Required system packages
  environment.systemPackages = with pkgs; [
    fuse
  ];
}
