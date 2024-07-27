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
      evince # document viewer
    ])
    ++ (with pkgs.gnome; [
      gnome-music
      gnome-characters
      tali # poker game
      iagno # go game
      hitori # sudoku game
      atomix # puzzle game
    ]);

  # Enable automatic login for the user.
  services.getty.autologinUser = "nepjua";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.xserver.enable = true;

  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
}
