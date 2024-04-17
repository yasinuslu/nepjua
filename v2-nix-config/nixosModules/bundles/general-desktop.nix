{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.05";

  myNixOS.xserver-nvidia.enable = lib.mkDefault true;
  myNixOS.gnome.enable = lib.mkDefault true;
  
  zramSwap.enable = true;

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

  nixpkgs = {
    config = {
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
    };
  };

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

  security.polkit.enable = true;
  services.gnome.gnome-remote-desktop.enable = true;

  # FIXME: Move to homeManager.features.fonts
  fonts.packages = with pkgs; [
    (nerdfonts.override {fonts = ["JetBrainsMono" "FiraCode"];})
  ];

  services.gnome.gnome-keyring.enable = true;


  # FIXME: Move this to features.sshServer
  services.openssh = {
    enable = true;
    allowSFTP = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = true;
      ForceCommand = "${pkgs.bash.outPath}/bin/bash";
    };
  };

  # FIXME: Move this to features.1password and homeManager if possible
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [config.users.users.nepjua.name];
  };

  programs._1password = {
    enable = true;
  };

  # FIXME: Move this to homeManager.features.gnome and features.gnome
  environment.gnome.excludePackages =
    (with pkgs; [
      gnome-photos
      gnome-tour
    ])
    ++ (with pkgs.gnome; [
      cheese # webcam tool
      gnome-music
      gnome-terminal
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

  # FIXME: This should be in features.qemuGuest
  services.qemuGuest.enable = false;
  services.spice-autorandr.enable = false;
  services.spice-vdagentd.enable = false;
  services.spice-webdavd.enable = false;

  # FIXME: Install All of these as home packages
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
    discord
  ];

  # FIXME: Put in features.docker
  virtualisation.docker.enable = true;
  virtualisation.docker.enableNvidia = true;
  virtualisation.docker.enableOnBoot = true;

  # Enable automatic login for the user.
  services.getty.autologinUser = "nepjua";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.xserver.enable = true;

  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
}
