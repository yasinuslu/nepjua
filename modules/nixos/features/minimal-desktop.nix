{ pkgs, config, ... }:
{
  # Enable X11 and basic desktop environment services
  services.xserver = {
    # Use i3 as the window manager
    windowManager.i3 = {
      enable = true;
      package = pkgs.i3-gaps;
      extraPackages = with pkgs; [
        dmenu # Application launcher
        i3status # Status bar
        i3lock # Screen locker
        dunst # Notification daemon
      ];
    };

    # Minimal display manager
    displayManager.lightdm = {
      enable = true;
      greeters.mini = {
        enable = true;
        user = config.myNixOS.mainUser;
        extraConfig = ''
          [greeter]
          show-password-label = false
          show-input-cursor = false
        '';
      };
    };

  };

  # Essential desktop packages
  environment.systemPackages = with pkgs; [
    # Terminal
    alacritty

    # Basic utilities
    rofi # Application launcher
    polybar # Status bar
    feh # Wallpaper setter
    picom # Compositor

    # Notification
    dunst

    # Screen management
    arandr

    # Clipboard management
    xclip

    # Screenshot
    flameshot
  ];

}
