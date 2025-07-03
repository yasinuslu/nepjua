# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{ config, ... }:
{
  networking.hostName = "joyboy";
  networking.computerName = "Joi Boi";

  sops.secrets."joyboy-combined-cert" = {
    key = "joyboy-combined-cert";
    mode = "0644";
  };

  security.pki.certificates = [
    (builtins.readFile config.sops.secrets."joyboy-combined-cert".path)
  ];

  myDarwin = {
    bundles.darwin-desktop.enable = true;

    users = {
      nepjua = {
        userConfig =
          { ... }:
          {
            programs.git.userName = "Yasin Uslu";
            programs.git.userEmail = "nepjua@gmail.com";
            myHomeManager.darwin.colima.enable = true;
            myHomeManager.deno.enable = true;
          };
        userSettings = { };
      };
    };
  };
}
