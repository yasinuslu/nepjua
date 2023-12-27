# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  wsl.enable = true;
  wsl.defaultUser = "nepjua";
  wsl.nativeSystemd = true;
  wsl.interop = {
    enable = true;
    defaultUser = "nepjua";
  };

  # # This setups a SSH server. Very important if you're setting up a headless system.
  # # Feel free to remove if you don't need it.
  # services.openssh = {
  #   enable = true;
  #   allowSFTP = true;
  #   settings = {
  #     PermitRootLogin = "yes";
  #     PasswordAuthentication = false;
  #     TCPKeepAlive = true;
  #     ClientAliveInterval = 60;
  #     ClientAliveCountMax = 120;
  #   };
  # };

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

  # Set your time zone.
  time.timeZone = "Europe/Istanbul";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";

  # i18n.extraLocaleSettings = {
  #   LC_ADDRESS = "en_US.UTF-8";
  #   LC_IDENTIFICATION = "en_US.UTF-8";
  #   LC_MEASUREMENT = "tr_TR.UTF-8";
  #   LC_MONETARY = "en_US.UTF-8";
  #   LC_NAME = "en_US.UTF-8";
  #   LC_NUMERIC = "en_US.UTF-8";
  #   LC_PAPER = "en_US.UTF-8";
  #   LC_TELEPHONE = "tr_TR.UTF-8";
  #   LC_TIME = "tr_TR.UTF-8";
  # };

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
      experimental-features = "nix-command flakes";
      # Deduplicate and optimize nix store
      auto-optimise-store = true;
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    htop
    git
    # _1password
  ];

  programs.fish.enable = true;

  # programs._1password = {
  #   enable = true;
  # };

  programs.java.enable = true;

  system.stateVersion = "23.11";
}
