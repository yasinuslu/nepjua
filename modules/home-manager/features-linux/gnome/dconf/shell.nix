# Generated via dconf2nix: https://github.com/gvolpe/dconf2nix
{ lib, ... }:

with lib.hm.gvariant;

{
  dconf.settings = {
    "org/gnome/shell" = {
      command-history = [ "r" ];
      disable-user-extensions = false;
      disabled-extensions = [ "extensions-sync@elhan.io" "apps-menu@gnome-shell-extensions.gcampax.github.com" "auto-move-windows@gnome-shell-extensions.gcampax.github.com" "launch-new-instance@gnome-shell-extensions.gcampax.github.com" "native-window-placement@gnome-shell-extensions.gcampax.github.com" ];
      enabled-extensions = [ "user-theme@gnome-shell-extensions.gcampax.github.com" "advanced-alt-tab@G-dH.github.com" "quick-settings-tweaks@qwreey" "appindicatorsupport@rgcjonas.gmail.com" ];
      favorite-apps = [ "google-chrome.desktop" "cursor.desktop" "lens-desktop.desktop" "org.gnome.Nautilus.desktop" "teams-for-linux.desktop" "jetbrains-datagrip-7d91d95e-427e-480c-843c-ba6f16b51474.desktop" ];
      last-selected-power-profile = "performance";
      welcome-dialog-last-shown-version = "43.2";
    };

    "extensions/advanced-alt-tab-window-switcher" = {
      animation-time-factor = 200;
      app-switcher-popup-icon-size = 96;
      app-switcher-popup-raise-first-only = true;
      app-switcher-popup-results-limit = 11;
      app-switcher-popup-search-pref-running = true;
      app-switcher-popup-sorting = 2;
      app-switcher-popup-titles = true;
      enable-super = false;
      hot-edge-mode = 0;
      hot-edge-monitor = 1;
      hot-edge-position = 2;
      hot-edge-width = 53;
      super-double-press-action = 3;
      super-key-mode = 1;
      switcher-popup-activate-on-hide = true;
      switcher-popup-hover-select = true;
      switcher-popup-monitor = 3;
      switcher-popup-pointer = true;
      switcher-popup-position = 2;
      switcher-popup-preview-selected = 2;
      switcher-popup-scroll-in = 0;
      switcher-popup-shift-hotkeys = false;
      switcher-popup-sync-filter = false;
      switcher-popup-timeout = 100;
      win-switcher-popup-order = 2;
      win-switcher-popup-scroll-item = 1;
      win-switcher-popup-search-all = true;
      win-switcher-popup-search-apps = true;
    };

    "extensions/pano" = {
      global-shortcut = [ "<Control><Alt>v" ];
    };

    "extensions/quick-settings-tweaks" = {
      list-buttons = "[{\"name\":\"SystemItem\",\"title\":null,\"visible\":true},{\"name\":\"OutputStreamSlider\",\"title\":null,\"visible\":true},{\"name\":\"InputStreamSlider\",\"title\":null,\"visible\":false},{\"name\":\"St_BoxLayout\",\"title\":null,\"visible\":true},{\"name\":\"BrightnessItem\",\"title\":null,\"visible\":false},{\"name\":\"NMWiredToggle\",\"title\":\"Wired\",\"visible\":true},{\"name\":\"NMWirelessToggle\",\"title\":\"Wi-Fi\",\"visible\":true},{\"name\":\"NMModemToggle\",\"title\":null,\"visible\":false},{\"name\":\"NMBluetoothToggle\",\"title\":null,\"visible\":false},{\"name\":\"NMVpnToggle\",\"title\":null,\"visible\":false},{\"name\":\"BluetoothToggle\",\"title\":\"Bluetooth\",\"visible\":true},{\"name\":\"PowerProfilesToggle\",\"title\":\"Power Mode\",\"visible\":true},{\"name\":\"NightLightToggle\",\"title\":\"Night Light\",\"visible\":true},{\"name\":\"DarkModeToggle\",\"title\":\"Dark Style\",\"visible\":true},{\"name\":\"KeyboardBrightnessToggle\",\"title\":\"Keyboard\",\"visible\":false},{\"name\":\"RfkillToggle\",\"title\":\"Airplane Mode\",\"visible\":false},{\"name\":\"RotationToggle\",\"title\":\"Auto Rotate\",\"visible\":false},{\"name\":\"DndQuickToggle\",\"title\":\"Do Not Disturb\",\"visible\":true},{\"name\":\"BackgroundAppsToggle\",\"title\":\"No Background Apps\",\"visible\":false},{\"name\":\"MediaSection\",\"title\":null,\"visible\":false},{\"name\":\"Notifications\",\"title\":null,\"visible\":false}]";
    };

    "extensions/user-theme" = {
      name = "";
    };

    "world-clocks" = {
      locations = [];
    };

  };
}
