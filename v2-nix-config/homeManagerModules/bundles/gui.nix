{
  lib,
  pkgs,
  ...
}: {
  myHomeManager.gui.enable = lib.mkDefault true;
}
