{pkgs}: let
  hoppscotch = import ./hoppscotch.nix {inherit (pkgs) appimageTools fetchurl;};
in {
  environment.systemPackages = [hoppscotch];
}
