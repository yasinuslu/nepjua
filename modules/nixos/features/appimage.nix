{pkgs, ...}: {
  # Enable AppImage support
  programs.appimage = {
    enable = true;
    # Enable binfmt support for AppImages
    binfmt = true;
    # Add extra packages for better compatibility
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

          # System libraries
          zlib
          glibc
          libGL
        ];
    };
  };

  # Required system packages for AppImage support
  environment.systemPackages = with pkgs; [
    # Core dependencies
    fuse
    appimage-run

    # Additional utilities
    file # for file type detection
    patchelf # for binary patching
  ];

  # Enable FUSE support (required for AppImage)
  boot.kernelModules = ["fuse"];

  # Configure system for AppImage execution
  boot.supportedFilesystems.fuse = true;

  # Allow users to mount FUSE filesystems
  security.wrappers.fusermount.source = "${pkgs.fuse}/bin/fusermount";
}
