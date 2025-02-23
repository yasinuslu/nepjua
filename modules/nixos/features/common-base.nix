{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
{
  zramSwap.enable = true;

  # Increase inotify watches
  boot.kernel.sysctl = {
    "fs.inotify.max_user_watches" = 8388608; # 2^23 (~8GB max kernel memory)
    "fs.inotify.max_user_instances" = 8388608; # 2^23
  };

  boot.supportedFilesystems = [
    "zfs"
    "ntfs"
    "ext4"
    "exfat"
  ];
  powerManagement.enable = false;

  # Set your time zone.
  time.timeZone = "Europe/Istanbul";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "tr_TR.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "tr_TR.UTF-8";
    LC_TIME = "tr_TR.UTF-8";
  };

  nixpkgs = {
    config = {
      allowUnfree = true;

      cores = lib.mkDefault 8;
      max-jobs = lib.mkDefault 6;

      permittedInsecurePackages = [
        "electron-27.3.11"
      ];
    };
  };

  nix = {
    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    # This will additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
  };

  programs.zsh.enable = true;
  programs.fish.enable = true;
}
