# Generated via dconf2nix: https://github.com/gvolpe/dconf2nix
{ lib, ... }:

with lib.hm.gvariant;

{
  dconf.settings = {
    "org/gnome/shell" = {
      command-history = [ "r" ];
      disable-user-extensions = false;
      disabled-extensions = [ "extensions-sync@elhan.io" "apps-menu@gnome-shell-extensions.gcampax.github.com" ];
      enabled-extensions = [ "user-theme@gnome-shell-extensions.gcampax.github.com" "advanced-alt-tab@G-dH.github.com" "quick-settings-tweaks@qwreey" "appindicatorsupport@rgcjonas.gmail.com" ];
      favorite-apps = [ "org.gnome.Geary.desktop" "org.gnome.Calendar.desktop" "org.gnome.Music.desktop" "org.gnome.Photos.desktop" "org.gnome.Nautilus.desktop" ];
      welcome-dialog-last-shown-version = "43.2";
    };

    "org/gnome/shell/extensions/advanced-alt-tab-window-switcher" = {
      enable-super = false;
      super-double-press-action = 3;
      super-key-mode = 1;
      switcher-popup-monitor = 3;
      switcher-popup-position = 2;
    };

    "org/gnome/shell/extensions/quick-settings-tweaks" = {
      list-buttons = "[{\"name\":\"Clutter_Actor\",\"label\":null,\"visible\":true},{\"name\":\"SystemItem\",\"label\":null,\"visible\":true},{\"name\":\"OutputStreamSlider\",\"label\":null,\"visible\":false},{\"name\":\"St_BoxLayout\",\"label\":null,\"visible\":true},{\"name\":\"InputStreamSlider\",\"label\":null,\"visible\":false},{\"name\":\"BrightnessItem\",\"label\":null,\"visible\":true},{\"name\":\"NMWiredToggle\",\"label\":null,\"visible\":true},{\"name\":\"NMWirelessToggle\",\"label\":null,\"visible\":true},{\"name\":\"NMModemToggle\",\"label\":null,\"visible\":true},{\"name\":\"NMBluetoothToggle\",\"label\":null,\"visible\":true},{\"name\":\"NMVpnToggle\",\"label\":null,\"visible\":true},{\"name\":\"BluetoothToggle\",\"label\":null,\"visible\":false},{\"name\":\"PowerProfilesToggle\",\"label\":null,\"visible\":false},{\"name\":\"NightLightToggle\",\"label\":\"Night Light\",\"visible\":true},{\"name\":\"DarkModeToggle\",\"label\":\"Dark Style\",\"visible\":true},{\"name\":\"RfkillToggle\",\"label\":\"Airplane Mode\",\"visible\":false},{\"name\":\"RotationToggle\",\"label\":\"Auto Rotate\",\"visible\":false},{\"name\":\"DndQuickToggle\",\"label\":null,\"visible\":true},{\"name\":\"BackgroundAppsToggle\",\"label\":null,\"visible\":false},{\"name\":\"MediaSection\",\"label\":null,\"visible\":false},{\"name\":\"Notifications\",\"label\":null,\"visible\":false}]";
    };

    "org/gnome/tweaks" = {
      show-extensions-notice = false;
    };

  };
}
