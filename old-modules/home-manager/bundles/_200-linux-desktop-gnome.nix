{ lib, ... }:
{
  myHomeManager = {
    bundles._125-linux-base.enable = lib.mkOverride 200 true;
    linux = {
      editor.enable = lib.mkOverride 200 true;
      gnome.enable = lib.mkOverride 200 true;
      _1password.enable = lib.mkOverride 200 true;
      autorandr.enable = lib.mkOverride 200 true;
      browser.enable = lib.mkOverride 200 true;
      gui.enable = lib.mkOverride 200 true;
      jetbrains.enable = lib.mkOverride 200 true;
    };
  };
}
