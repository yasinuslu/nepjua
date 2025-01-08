# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{ ... }:
{
  networking.hostName = "musu";
  networking.computerName = "Musu Mac";

  myDarwin = {
    bundles.general-desktop.enable = true;

    darwin-users = {
      nepjua = {
        userConfig =
          { ... }:
          {
            myHomeManager = {
              bundles.tui.enable = true;
              bundles.gui.enable = false;
            };

            programs.git = {
              userEmail = "msaiduslu@gmail.com";
              userName = "Muhammed Said Uslu";
            };
          };
        userSettings = { };
      };
    };
  };
}
