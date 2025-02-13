{ pkgs, ... }:
{
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      ovmf = {
        enable = true;
        packages = [ pkgs.OVMFFull.fd ];
      };
      runAsRoot = true;
      swtpm = {
        enable = true;
      };
    };
  };

  virtualisation.spiceUSBRedirection.enable = true;

  services.spice-vdagentd.enable = true;

  programs.virt-manager.enable = true;

}
