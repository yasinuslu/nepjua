{pkgs, ...}: {
  nixpkgs.overlays = [];

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    bashInteractive
    zsh
    fish
    act
    openssh
  ];

  environment.shells = [pkgs.bashInteractive pkgs.zsh pkgs.fish];
  programs.bash.enable = true;
  programs.zsh.enable = true;
  programs.fish.enable = true;

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  system.defaults = {
    dock = {
      autohide = true;
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

    screencapture.location = "~/Desktop/screencapture";

    trackpad = {
      Clicking = true;
      TrackpadThreeFingerDrag = true;
    };
  };
}
