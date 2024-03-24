{
  inputs,
  lib,
  config,
  pkgs,
  colors,
  ...
}: {
  # services.xrdp.enable = true;
  # services.xrdp.openFirewall = true;
  # services.xrdp.defaultWindowManager = "gnome-session";

  services.xserver.xkb.layout = "us";
  services.xserver.xkb.variant = "";

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.videoDrivers = ["nouveau"];
  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = true;
  services.xserver.desktopManager.gnome.enable = true;
  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  services.autorandr.enable = true;
  services.autorandr.profiles.multi = {
    fingerprint = {
      dp2-2k-oled = "00ffffffffffff004c2df2720000000008200104b55123783bbc55b04d3db7250f505421080081c0810081809500a9c0b300010101016d8870a0d0a0b25030203a0029623100001a000000fd0c30af1e1e66010a202020202020000000fc004f647973736579204738355342000000ff004831414b3530303030300a202002af020330f144903f04032309070783010000e305c3016d1a0000020730af000460024b02e6060501604a00e5018b849039565e00a0a0a029503020350029623100001a6fc200a0a0a055503020350029623100001a0474801871382d40582c450029623100001e00000000000000000000000000000000000000000000000000987012790300030150f21001886f0d9f002f801f009f05b10002000900568e01086f0d9f002f801f009f05b200020009004e230108ff099f002f801f009f057e0002000400fda600087f079f002f801f0037045e00020004000000000000000000000000000000000000000000000000000000000000000000000000000000bf90";
      dp4-hd = "00ffffffffffff004c2d281035375743321d0104a5351e783b2a15aa54499f24145054bfef80714f81c0810081809500a9c0b300d1c02a4480a070382740302035000f282100001a000000fd00304b545412010a202020202020000000fc00533234523635780a2020202020000000ff004834544d4330303535300a2020019302030ff14290452309070783010000023a801871382d40582c45000f282100001e011d007251d01e206e2855000f282100001e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ad";
    };
    config = {
      dp4-hd = {
        enable = true;
        primary = false;
        mode = "1920x1080";
        rate = "75";
        position = "0x360";
        scale = {
          x = 1;
          y = 1;
          method = "factor";
        };
      };
      dp2-2k-oled = {
        enable = true;
        primary = true;
        position = "right-of dp4-hd";
        mode = "3440x1440";
        rate = "174.96";
        scale = {
          x = 2;
          y = 2;
          method = "factor";
        };
      };
    };
  };
}
