# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  lib,
  pkgs,
  config,
  ...
}: {
  wsl.enable = true;
  wsl.defaultUser = "nepjua";
  wsl.nativeSystemd = true;

  environment.shellAliases = {
    ssh = "ssh.exe";
    ssh-add = "ssh-add.exe";
  };

  users.users = {
    nepjua = {
      initialPassword = "line-flanker-wingman-sidle";
      isNormalUser = true;
      description = "Yasin Uslu";
      openssh.authorizedKeys.keys = [''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDuVv6WeFdiZ+xfszM28cDmQM1yL0qw4TtMfzMzu5/zd''];
      extraGroups = ["networkmanager" "wheel" "docker" "podman"];
      shell = pkgs.fish;
    };

    root = {
      openssh.authorizedKeys.keys = [''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDuVv6WeFdiZ+xfszM28cDmQM1yL0qw4TtMfzMzu5/zd''];
    };
  };

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # If you want to use overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;

      permittedInsecurePackages = [
        "electron-25.9.0"
      ];
    };
  };

  nix = {
    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    registry = lib.mapAttrs (_: value: {flake = value;}) inputs;

    # This will additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes configurable-impure-env auto-allocate-uids";
      accept-flake-config = true;
      auto-optimise-store = true;
      auto-allocate-uids = true;
      # impure-env = true;
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    htop
    git
    steam-run
    # _1password
  ];

  programs.fish.enable = true;
  programs.java.enable = true;

  system.stateVersion = "23.11";
}
