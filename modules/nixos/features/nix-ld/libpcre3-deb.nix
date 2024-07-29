{pkgs ? import <nixpkgs> {}}:
pkgs.dpkg-buildpackage {
  name = "libpcre3-deb";
  src = pkgs.fetchurl {
    url = "http://ftp.debian.org/debian/pool/main/p/pcre3/libpcre3_8.39-12_amd64.deb";
    sha256 = "0r6cia5sdkvrn2z2njs7wzbv1r98xc9jlhvbp7cqw3r3q97awmy8"; # Replace with actual hash
  };
}
