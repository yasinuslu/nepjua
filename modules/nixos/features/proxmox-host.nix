{ inputs, myArgs, ... }:
{
  imports = [
    ./custom-hardware-configuration.nix
    inputs.proxmox-nixos.nixosModules.proxmox-ve
    (
      { ... }:
      {
        nixpkgs.overlays = [
          inputs.proxmox-nixos.overlays.${myArgs.system}
        ];

        services.proxmox-ve = {
          enable = true;
          ipAddress = "192.168.50.50";
        };
      }
    )
  ];

  systemd.network.networks."10-lan" = {
    matchConfig.Name = [ "ens18" ];
    networkConfig = {
      Bridge = "vmbr0";
    };
  };

  systemd.network.netdevs."vmbr0" = {
    netdevConfig = {
      Name = "vmbr0";
      Kind = "bridge";
    };
  };

  systemd.network.networks."10-lan-bridge" = {
    matchConfig.Name = "vmbr0";
    networkConfig = {
      IPv6AcceptRA = true;
      DHCP = "ipv4";
    };
    linkConfig.RequiredForOnline = "routable";
  };
}
