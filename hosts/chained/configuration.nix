# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  config,
  ...
}:
{
  networking.hostName = "chained";
  networking.computerName = "Yasin Uslu MC";

  security.pki.certificates =
    let
      certsDir = "/Users/yahmet/code/nepjua/.generated/certs";
      certFiles = builtins.readDir certsDir;
      certContents = builtins.filter (name: builtins.match ".*\\.crt$" name != null) (
        builtins.attrNames certFiles
      );
      readCertFile = file: builtins.readFile (certsDir + "/" + file);
    in
    map readCertFile certContents;

  myDarwin = {
    bundles.darwin-desktop.enable = true;

    homebrew-extra.enable = false;

    users = {
      yahmet = {
        userConfig =
          { ... }:
          {
            programs.git.userName = "TO BE SET";
            programs.git.userEmail = "to-be-set@example.com";

            myHomeManager = {
              # impure-node.enable = false;
            };
          };
        userSettings = { };
      };
    };
  };
}
