{pkgs ? import <nixpkgs> {}}: let
  inherit (pkgs) stdenv fetchurl dpkg lib;
in
  stdenv.mkDerivation rec {
    pname = "libpcre3-deb";
    version = "2:8.39-12";

    src = fetchurl {
      url = "http://ftp.debian.org/debian/pool/main/p/pcre3/libpcre3_8.39-12_amd64.deb";
      sha256 = "sha256-VJbqRrgSsaABBPyXsw4T/F+Pbp7BKKj/T9LWaoDMa+4="; # You'll need to replace this with the actual hash
    };

    nativeBuildInputs = [dpkg];

    unpackPhase = "dpkg-deb -x $src .";

    installPhase = ''
      mkdir -p $out/lib
      cp -R ./lib/x86_64-linux-gnu/* $out/lib
      cp -R ./usr/lib/x86_64-linux-gnu/* $out/lib
    '';

    meta = with lib; {
      description = "Perl 5 Compatible Regular Expression Library";
      homepage = "https://www.pcre.org/";
      license = licenses.bsd3;
      platforms = platforms.linux;
    };
  }
