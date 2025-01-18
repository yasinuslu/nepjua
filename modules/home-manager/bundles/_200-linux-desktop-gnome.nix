{ lib, ... }:
{
  myHomeManager = {
    bundles._100-linux-base.enable = lib.mkOverride 150 true;
    linux = {
      editor.enable = lib.mkOverride 150 true;
      gnome.enable = lib.mkOverride 150 true;
      _1password.enable = lib.mkOverride 150 true;
      autorandr.enable = lib.mkOverride 150 true;
      browser.enable = lib.mkOverride 150 true;
      gui.enable = lib.mkOverride 150 true;
      jetbrains.enable = lib.mkOverride 150 true;
    };
  };
}
