{
  pkgs,
  config,
  ...
}:
{
  # Enable the X11 windowing system.
  services.xserver.enable = true;

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.libinput = {
    enable = true;
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  environment.systemPackages = with pkgs; [
    mesa-demos
    # nixgl.auto.nixGLDefault
  ];

  # XDG desktop integration
  # xdg.portal = {
  #   enable = true;
  #   extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  # };

  # Enable D-Bus
  services.dbus.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Enable automatic login for the user.
  services.getty.autologinUser = config.myNixOS.mainUser;

  services.printing.enable = true;
}
