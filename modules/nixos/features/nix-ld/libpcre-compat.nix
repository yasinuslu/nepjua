{pkgs, ...}:
pkgs.stdenv.mkDerivation {
  name = "libpcre-compat";
  buildInputs = [pkgs.xlights];
  phases = ["installPhase"];
  installPhase = ''
    mkdir -p $out/lib
    cp ${pkgs.xlights}/usr/lib/libpcre.so.3 $out/lib/
  '';
}
