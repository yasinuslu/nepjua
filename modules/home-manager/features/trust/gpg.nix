{ pkgs, ... }:
{
  programs.gpg = {
    enable = true;
    settings = {
      # Common settings for better security and usability
      keyserver = "hkps://keys.openpgp.org";
      no-emit-version = true;
      no-comments = true;
      keyid-format = "0xlong";
      with-fingerprint = true;
      trust-model = "tofu+pgp";
    };
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = false; # Set to true if you want to use GPG for SSH authentication
    pinentryFlavor = "curses"; # Options: curses, tty, gtk2, qt

    # Cache settings
    defaultCacheTtl = 3600; # 1 hour
    defaultCacheTtlSsh = 3600; # 1 hour
    maxCacheTtl = 86400; # 1 day
    maxCacheTtlSsh = 86400; # 1 day
  };
}
