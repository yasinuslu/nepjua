{pkgs, ...}: {
  home.packages = [
    pkgs.xorg.xrandr
  ];

  nixpkgs.overlays = [
    (let
      autorandrPkgs = import (builtins.fetchTarball {
        url = "https://github.com/NixOS/nixpkgs/archive/5a8650469a9f8a1958ff9373bd27fb8e54c4365d.tar.gz";
      }) {};
    in (final: previous: {
      autorandr = autorandrPkgs.autorandr;
    }))
  ];

  # x = ''xrandr --newmode "2560x1080_175.00"  748.00  2560 2784 3064 3568  1080 1083 1093 1199 -hsync +vsync'';
  # x = ''xrandr --addmode DP-2 "2560x1080_175.00"'';

  # services.autorandr.enable = true;
  # programs.autorandr.enable = true;
  # # programs.autorandr.defaultTarget = "multi";
  # programs.autorandr.profiles.multi = {
  #   hooks = {
  #     preswitch = ''
  #       alias xrandr="${pkgs.xorg.xrandr.outPath}/bin/xrandr"

  #       xrandr --delmode DP-2 "2584x1080_175.00" 2>/dev/null
  #       xrandr --rmmode "2584x1080_175.00" 2>/dev/null
  #       xrandr --newmode "2584x1080_175.00"  756.50  2584 2816 3096 3608  1080 1083 1093 1199 -hsync +vsync
  #       xrandr --addmode DP-2 "2584x1080_175.00"

  #       xrandr --delmode DP-2 "2584x1080_120.00" 2>/dev/null
  #       xrandr --rmmode "2584x1080_120.00" 2>/dev/null
  #       xrandr --newmode "2584x1080_120.00"  497.50  2584 2800 3080 3576  1080 1083 1093 1160 -hsync +vsync
  #       xrandr --addmode DP-2 "2584x1080_120.00"

  #     '';
  #   };
  #   fingerprint = {
  #     DP-2 = "00ffffffffffff004c2df2720000000008200104b55123783bbc55b04d3db7250f505421080081c0810081809500a9c0b300010101016d8870a0d0a0b25030203a0029623100001a000000fd0c30af1e1e66010a202020202020000000fc004f647973736579204738355342000000ff004831414b3530303030300a202002af020330f144903f04032309070783010000e305c3016d1a0000020730af000460024b02e6060501604a00e5018b849039565e00a0a0a029503020350029623100001a6fc200a0a0a055503020350029623100001a0474801871382d40582c450029623100001e00000000000000000000000000000000000000000000000000987012790300030150f21001886f0d9f002f801f009f05b10002000900568e01086f0d9f002f801f009f05b200020009004e230108ff099f002f801f009f057e0002000400fda600087f079f002f801f0037045e00020004000000000000000000000000000000000000000000000000000000000000000000000000000000bf90";
  #     DP-4 = "00ffffffffffff004c2d281035375743321d0104a5351e783b2a15aa54499f24145054bfef80714f81c0810081809500a9c0b300d1c02a4480a070382740302035000f282100001a000000fd00304b545412010a202020202020000000fc00533234523635780a2020202020000000ff004834544d4330303535300a2020019302030ff14290452309070783010000023a801871382d40582c45000f282100001e011d007251d01e206e2855000f282100001e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ad";
  #   };
  #   config = {
  #     DP-4 = {
  #       enable = true;
  #       primary = false;
  #       mode = "1920x1080";
  #       rate = "75";
  #       position = "0x360";
  #       # scale = {
  #       #   x = 1;
  #       #   y = 1;
  #       #   method = "factor";
  #       # };
  #     };
  #     DP-2 = {
  #       enable = true;
  #       primary = true;
  #       position = "1920x0";
  #       # mode = "2580x1080_175";
  #       mode = "3440x1440";
  #       rate = "175.00";
  #       # scale = {
  #       #   x = 0.75;
  #       #   y = 0.75;
  #       #   method = "factor";
  #       # };
  #     };
  #   };
  # };
}
