# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{ ... }:
{
  networking.hostName = "sezer";
  networking.computerName = "sezer";

  myDarwin = {
    bundles.darwin-desktop.enable = true;

    users = {
      sezertogantemur = {
        userConfig =
          { ... }:
          {
            programs.git.userName = "Dev-Sezer";
            programs.git.userEmail = "stogantemur8@gmail.com";
            myHomeManager.darwin.colima.enable = true;
            myHomeManager.deno.enable = false;
          };
        userSettings = { };
      };
    };
  };
}
