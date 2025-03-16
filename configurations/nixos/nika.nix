{ lib, self, ... }:
{
  imports = [
    self.nixosModules.default
  ];

  networking.hostName = "nika";
  networking.hostId = "e5fda3f2";
  networking.firewall.enable = false;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # my = {
  #   common = {
  #     defaultUser = "nepjua";
  #   };

  #   home = {
  #     users = {
  #       nepjua = {
  #         extraConfig = {
  #           programs.git.userName = "Yasin Uslu";
  #           programs.git.userEmail = "nepjua@gmail.com";
  #         };

  #         extraSettings = {
  #           extraGroups = [
  #             "networkmanager"
  #             "wheel"
  #             "adbusers"
  #             "docker"
  #             "lxd"
  #             "kvm"
  #             "libvirtd"
  #           ];
  #         };
  #       };
  #     };
  #   };
  # };
}
