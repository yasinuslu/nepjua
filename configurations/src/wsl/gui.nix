# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  config,
  pkgs,
  ...
}: {
  # environment.sessionVariables = {
  #   XDG_DATA_DIRS = "/var/lib/flatpak/exports/share:$HOME/share/flatpak/exports/share";
  # };

  # Set your time zone.
  time.timeZone = "Europe/Istanbul";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.supportedLocales = [
    "en_US.UTF-8/UTF-8"
    "tr_TR.UTF-8/UTF-8"
  ];

  # Enable automatic login for the user.
  # services.getty.autologinUser = "nepjua";

  # List packages installed in system profile. To search, run:
  environment.systemPackages = with pkgs; [
    gparted
    _1password
    _1password-gui
    gnome.dconf-editor
    vlc
    copyq
    parsec-bin
    obs-studio
    bottles
    qbittorrent
    discord
    slack
    obsidian
    zoom-us
    spotify
    google-chrome
    microsoft-edge
    glxinfo
    gnome.gnome-session
  ];

  services.spotifyd = {
    enable = true;
  };

  xdg.portal.enable = true;
  services.flatpak.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.videoDrivers = ["nvidia"];
  hardware.opengl.enable = true;
  hardware.opengl.driSupport = true;

  programs.hyprland.enable = true;

  # # Enable the GNOME Desktop Environment.
  # services.xserver.displayManager.gdm.enable = true;
  # services.xserver.displayManager.gdm.wayland = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

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

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  programs.fish.enable = true;

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

  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [config.users.users.nepjua.name];
  };

  programs._1password = {
    enable = true;
  };

  # This setups a SSH server. Very important if you're setting up a headless system.
  # Feel free to remove if you don't need it.
  # services.openssh = {
  #   enable = true;
  #   allowSFTP = true;
  #   settings = {
  #     PermitRootLogin = "yes";
  #     PasswordAuthentication = true;
  #   };
  # };

  fonts.packages = with pkgs; [
    (nerdfonts.override {fonts = ["JetBrainsMono" "FiraCode"];})
  ];

  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;
}
