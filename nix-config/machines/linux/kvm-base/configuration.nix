# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    # FIXME: Generate this import with `nixos-generate-config`
    /etc/nixos/hardware-configuration.nix
    ./gaming
    ./display.nix
  ];

  zramSwap.enable = true;

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [80 443 22 3386];
    allowedUDPPorts = [];
    allowedTCPPortRanges = [
      {
        from = 20000;
        to = 21000;
      }
    ];
    allowedUDPPortRanges = [
      {
        from = 20000;
        to = 21000;
      }
    ];
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable networking
  networking.networkmanager.enable = true;

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

  users.users = {
    nepjua = {
      initialPassword = "line-flanker-wingman-sidle";
      isNormalUser = true;
      description = "Yasin Uslu";
      openssh.authorizedKeys.keys = [''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAJdpt9EGv3VZwkxRUP0M90kVkkOCtC+huewLt6NJhKg''];
      extraGroups = ["networkmanager" "wheel" "docker"];
      shell = pkgs.fish;
    };

    root = {
      openssh.authorizedKeys.keys = [''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAJdpt9EGv3VZwkxRUP0M90kVkkOCtC+huewLt6NJhKg''];
    };
  };

  # Enable automatic login for the user.
  services.getty.autologinUser = "nepjua";

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
      experimental-features = "nix-command flakes auto-allocate-uids";
      accept-flake-config = true;
      auto-optimise-store = true;
      auto-allocate-uids = true;
      trusted-users = ["root" "nepjua"];
      cores = 6;
      max-jobs = 6;
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    gparted
    htop
    git
    _1password
    _1password-gui
    gnome.dconf-editor
    cachix
    nixd
    busybox
    xrdp
  ];

  programs.fish.enable = true;
  programs.java.enable = true;

  services.flatpak.enable = true;

  services.qemuGuest.enable = true;
  services.spice-autorandr.enable = false;
  services.spice-vdagentd.enable = false;
  services.spice-webdavd.enable = false;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  environment.gnome.excludePackages =
    (with pkgs; [
      gnome-photos
      gnome-tour
    ])
    ++ (with pkgs.gnome; [
      cheese # webcam tool
      gnome-music
      gnome-terminal
      # FIXME: figure out what to do here
      # gedit # text editor
      epiphany # web browser
      geary # email reader
      evince # document viewer
      gnome-characters
      totem # video player
      tali # poker game
      iagno # go game
      hitori # sudoku game
      atomix # puzzle game
    ]);

  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [config.users.users.nepjua.name];
  };

  programs._1password = {
    enable = true;
  };

  # This setups a SSH server. Very important if you're setting up a headless system.
  # Feel free to remove if you don't need it.
  services.openssh = {
    enable = true;
    allowSFTP = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = true;
    };
  };

  fonts.packages = with pkgs; [
    (nerdfonts.override {fonts = ["JetBrainsMono" "FiraCode"];})
  ];

  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;
  services.gnome.gnome-remote-desktop.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
