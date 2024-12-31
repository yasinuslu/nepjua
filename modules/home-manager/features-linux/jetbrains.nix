{pkgs, ...}: {
  home.packages = with pkgs;
    if pkgs.stdenv.system == "x86_64-linux"
    then [jetbrains-toolbox]
    else [];
}
