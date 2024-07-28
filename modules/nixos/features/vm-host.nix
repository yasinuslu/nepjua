{...}: {
  virtualisation.libvirtd.enable = true;
  virtualisation.libvirtd.qemu.ovmf.enable = true;
  virtualisation.libvirtd.qemu.runAsRoot = true;

  programs.virt-manager.enable = true;
}
