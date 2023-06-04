{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  fileSystems."/mnt/ayame" = {
    device = "/dev/nvme0n1p2";
    fsType = "btrfs";
  };

  fileSystems."/home/nepjua/ayame" = {
    device = "/mnt/ayame";
    options = ["bind"];
  };

  fileSystems."/export/ayame" = {
    device = "/mnt/ayame";
    options = ["bind"];
  };

  services.nfs.server = {
    enable = true;
    # fixed rpc.statd port; for firewall
    lockdPort = 4001;
    mountdPort = 4002;
    statdPort = 4000;
    extraNfsdConfig = '''';
    exports = ''
      /export         192.168.50.21(rw,fsid=0,no_subtree_check) 192.168.50.22(rw,fsid=0,no_subtree_check)
      /export/ayame  192.168.50.21(rw,nohide,insecure,no_subtree_check) 192.168.50.22(rw,nohide,insecure,no_subtree_check)
    '';
  };

  networking.firewall = {
    enable = true;
    # for NFSv3; view with `rpcinfo -p`
    allowedTCPPorts = [111 2049 4000 4001 4002 20048];
    allowedUDPPorts = [111 2049 4000 4001 4002 20048];
  };
}
