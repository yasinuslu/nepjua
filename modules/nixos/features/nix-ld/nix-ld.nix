{pkgs, ...}: let
  nixLdWrapper = pkgs.writeScriptBin "nix-ld" ''
    #!${pkgs.stdenv.shell}
    export LD_LIBRARY_PATH=$NIX_LD_LIBRARY_PATH
    exec "$@"
  '';
in {
  environment.systemPackages = [
    nixLdWrapper
  ];

  programs.nix-ld.enable = true;
}
