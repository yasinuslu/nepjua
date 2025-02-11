{ pkgs, ... }:
{
  services.darkman = {
    enable = true;
    settings = {
      lat = 39.9032594;
      lng = 32.5976167;
      usegeoclue = false;
    };
    lightModeScripts = {
      gtk-theme = ''
        ${pkgs.dconf}/bin/dconf write \
            /org/gnome/desktop/interface/color-scheme "'prefer-light'"
      '';
    };
    darkModeScripts = {
      gtk-theme = ''
        ${pkgs.dconf}/bin/dconf write \
            /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
      '';
    };
  };
}
