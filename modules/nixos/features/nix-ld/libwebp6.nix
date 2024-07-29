{pkgs, ...}:
pkgs.stdenv.mkDerivation {
  name = "libwebp6";

  buildInputs = [pkgs.libwebp];

  installPhase = ''
    mkdir -p $out/lib
    ln -s ${pkgs.libwebp}/lib/libwebp.so.7 $out/lib/libwebp.so.6
  '';

  meta = with pkgs.lib; {
    description = "libwebp6 symlink for compatibility";
    license = licenses.lgpl21Plus;
  };
}
