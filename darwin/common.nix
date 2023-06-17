{
  config,
  pkgs,
  ...
}: {
  nix.extraOptions = ''
    extra-nix-path = nixpkgs=flake:nixpkgs
    bash-prompt-prefix = (nix:$name)\040
    auto-optimise-store = true
    build-users-group = nixbld
    experimental-features = nix-command flakes
    extra-platforms = aarch64-darwin x86_64-darwin
  '';

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
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    bashInteractive
    zsh
    fish
  ];

  environment.shells = [pkgs.bashInteractive pkgs.zsh pkgs.fish];
  programs.zsh.enable = true;
  programs.fish.enable = true;

  environment.shellAliases = {
    docker = "podman";
    "docker-compose" = "podman-compose";
  };
  services.spotifyd.enable = true;

  homebrew = {
    enable = true;
    brews = [
      "podman"
      "podman-compose"
    ];
    casks = [
      "google-chrome"
      "1password"
      "alt-tab"
      "iterm2"
      "microsoft-edge"
      "copyq"
      "visual-studio-code"
      "rectangle"
      "slack"
      "microsoft-office"
      "zoom"
      "podman-desktop"
      "whatsapp"
      "notion"
      "obsidian"
      "spotify"
      "steam"
      "vlc"
      "qbittorrent"
    ];
  };

  fonts = {
    fontDir.enable = true;
    fonts = with pkgs; [
      (nerdfonts.override {fonts = ["JetBrainsMono" "FiraCode"];})
    ];
  };

  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
  # environment.darwinConfig = "$HOME/.config/nixpkgs/darwin/configuration.nix";

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;

  system.keyboard = {
    enableKeyMapping = true;
    nonUS.remapTilde = true;
  };

  system.defaults = {
    dock = {
      autohide = true;
      # orientation = "right";
    };

    finder = {
      AppleShowAllExtensions = true;
      _FXShowPosixPathInTitle = true;
      FXEnableExtensionChangeWarning = false;
    };

    NSGlobalDomain = {
      _HIHideMenuBar = false;
      "com.apple.swipescrolldirection" = true;
    };

    screencapture.location = "/tmp";

    trackpad = {
      Clicking = true;
      TrackpadThreeFingerDrag = true;
    };
  };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
