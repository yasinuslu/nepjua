{pkgs, ...}: {
  # Required system packages for AppImage support
  environment.systemPackages = with pkgs; [
    # Core dependencies
    fuse
    appimage-run

    # Additional utilities
    file # for file type detection
    patchelf # for binary patching
    zlib # compression support
  ];

  # Enable FUSE support (required for AppImage)
  boot.kernelModules = ["fuse"];

  # Configure system for AppImage execution
  boot.supportedFilesystems = {
    fuse = true;
  };

  # Allow users to mount FUSE filesystems
  security.wrappers.fusermount.source = "${pkgs.fuse}/bin/fusermount";
}
