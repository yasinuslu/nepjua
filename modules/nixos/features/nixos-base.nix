{
  pkgs,
  config,
  ...
}: {
  zramSwap.enable = true;

  # Enable networking
  networking.networkmanager.enable = true;

  # Enable sound with pipewire.
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
      cheese
      gnome-terminal
      epiphany # web browser
      geary # email reader
      totem # video player
    ])
    ++ (with pkgs.gnome; [
      gnome-music
      evince # document viewer
      gnome-characters
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
    _1password # FIXME: Move to home-manager
    _1password-gui # FIXME: Move to home-manager
    gnome.dconf-editor # FIXME: Move to home-manager
    xrdp # FIXME: Move to home-manager
    discord # FIXME: Move to home-manager
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
