# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{ ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "kamina";

  myNixOS = {
    mainUser = "nepjua";
    bundles.minimal.enable = true;

    users = {
      nepjua = {
        userConfig =
          { ... }:
          {
            programs.git.userName = "Yasin Uslu";
            programs.git.userEmail = "nepjua@gmail.com";

            myHomeManager.docker.enable = false;

            # Disable all gui stuff
            myHomeManager.linux.editor.enable = true;
            myHomeManager.linux.gnome.enable = false;
            myHomeManager.linux._1password.enable = false;
            myHomeManager.linux.autorandr.enable = false;
            myHomeManager.linux.browser.enable = false;
            myHomeManager.linux.gui.enable = false;
            myHomeManager.linux.jetbrains.enable = false;

            # Only enable base stuff
            myHomeManager.linux.base.enable = true;
          };

        userSettings = {
          extraGroups = [
            "networkmanager"
            "wheel"
            "adbusers"
            "docker"
            "lxd"
            "kvm"
            "libvirtd"
          ];
        };
      };
    };
  };
}
