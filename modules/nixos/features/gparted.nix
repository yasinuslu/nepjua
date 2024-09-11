{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    gparted
    exfatprogs
  ];
}
