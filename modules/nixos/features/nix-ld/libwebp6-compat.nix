{pkgs}:
pkgs.stdenv.mkDerivation {
  name = "libwebp6-compat";

  buildInputs = [pkgs.libwebp];

  unpackPhase = "true";

  installPhase = ''
    mkdir -p $out/lib
    ln -s ${pkgs.libwebp}/lib/libwebp.so.7 $out/lib/libwebp.so.6
  '';

  meta = with pkgs.lib; {
    description = "Compatibility layer for libwebp.so.6";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
