{
  lib,
  stdenv,
  fetchurl,
}:
stdenv.mkDerivation rec {
  pname = "libwebp";
  version = "0.6.1";

  src = fetchurl {
    url = "https://storage.googleapis.com/downloads.webmproject.org/releases/webp/${pname}-${version}.tar.gz";
    sha256 = "06592k2n10a7wq75kp2rn3di345hhy5z4jaalk2zyj8na2sxfksy";
  };

  meta = with lib; {
    description = "WebP image format library (version 0.6.1)";
    homepage = "https://developers.google.com/speed/webp/";
    license = licenses.bsd3;
    platforms = platforms.all;
  };
}
