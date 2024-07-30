# Generated via dconf2nix: https://github.com/gvolpe/dconf2nix
{lib, ...}:
with lib.hm.gvariant; {
  dconf.settings = {
    "ca/desrt/dconf-editor" = {
      show-warning = false;
    };

    "org/gnome/Snapshot" = {
      is-maximized = false;
      window-height = 640;
      window-width = 800;
    };

    "org/gnome/calendar" = {
      active-view = "month";
    };

    "org/gnome/control-center" = {
      last-panel = "sound";
      window-state = mkTuple [858 518 true];
    };

    "org/gnome/desktop/app-folders" = {
      folder-children = ["Utilities" "YaST" "Pardus"];
    };

    "org/gnome/desktop/app-folders/folders/Pardus" = {
      categories = ["X-Pardus-Apps"];
      name = "X-Pardus-Apps.directory";
      translate = true;
    };

    "org/gnome/desktop/app-folders/folders/Utilities" = {
      apps = ["gnome-abrt.desktop" "gnome-system-log.desktop" "nm-connection-editor.desktop" "org.gnome.baobab.desktop" "org.gnome.Connections.desktop" "org.gnome.DejaDup.desktop" "org.gnome.Dictionary.desktop" "org.gnome.DiskUtility.desktop" "org.gnome.Evince.desktop" "org.gnome.FileRoller.desktop" "org.gnome.fonts.desktop" "org.gnome.Loupe.desktop" "org.gnome.seahorse.Application.desktop" "org.gnome.tweaks.desktop" "org.gnome.Usage.desktop" "vinagre.desktop"];
      categories = ["X-GNOME-Utilities"];
      name = "X-GNOME-Utilities.directory";
      translate = true;
    };

    "org/gnome/desktop/app-folders/folders/YaST" = {
      categories = ["X-SuSE-YaST"];
      name = "suse-yast.directory";
      translate = true;
    };

    "org/gnome/desktop/background" = {
      color-shading-type = "solid";
      picture-options = "zoom";
      picture-uri = "file:///run/current-system/sw/share/backgrounds/gnome/adwaita-l.jpg";
      picture-uri-dark = "file:///run/current-system/sw/share/backgrounds/gnome/adwaita-d.jpg";
      primary-color = "#3071AE";
      secondary-color = "#000000";
    };

    "org/gnome/desktop/input-sources" = {
      sources = [(mkTuple ["xkb" "us"])];
      xkb-options = ["terminate:ctrl_alt_bksp"];
    };

    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      cursor-theme = "Adwaita";
      document-font-name = "Cantarell 11";
      font-antialiasing = "grayscale";
      font-hinting = "slight";
      font-name = "Cantarell 11";
      gtk-theme = "Adwaita";
      icon-theme = "Adwaita";
      monospace-font-name = "JetBrainsMono Nerd Font Mono 11";
      text-scaling-factor = 1.2;
    };

    "org/gnome/desktop/notifications" = {
      application-children = ["gnome-power-panel" "code" "discord" "google-chrome" "org-qbittorrent-qbittorrent" "org-gnome-extensions" "org-gnome-tweaks" "org-gnome-settings"];
    };

    "org/gnome/desktop/notifications/application/1password" = {
      application-id = "1password.desktop";
    };

    "org/gnome/desktop/notifications/application/code" = {
      application-id = "code.desktop";
    };

    "org/gnome/desktop/notifications/application/codium" = {
      application-id = "codium.desktop";
    };

    "org/gnome/desktop/notifications/application/dev-warp-warp" = {
      application-id = "dev.warp.Warp.desktop";
    };

    "org/gnome/desktop/notifications/application/discord" = {
      application-id = "discord.desktop";
    };

    "org/gnome/desktop/notifications/application/gnome-power-panel" = {
      application-id = "gnome-power-panel.desktop";
    };

    "org/gnome/desktop/notifications/application/google-chrome" = {
      application-id = "google-chrome.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-extensions" = {
      application-id = "org.gnome.Extensions.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-nautilus" = {
      application-id = "org.gnome.Nautilus.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-settings" = {
      application-id = "org.gnome.Settings.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-tweaks" = {
      application-id = "org.gnome.tweaks.desktop";
    };

    "org/gnome/desktop/notifications/application/org-qbittorrent-qbittorrent" = {
      application-id = "org.qbittorrent.qBittorrent.desktop";
    };

    "org/gnome/desktop/peripherals/keyboard" = {
      numlock-state = true;
    };

    "org/gnome/desktop/peripherals/touchpad" = {
      two-finger-scrolling-enabled = true;
    };

    "org/gnome/desktop/screensaver" = {
      color-shading-type = "solid";
      picture-options = "zoom";
      picture-uri = "file:///run/current-system/sw/share/backgrounds/gnome/adwaita-l.jpg";
      primary-color = "#3071AE";
      secondary-color = "#000000";
    };

    "org/gnome/desktop/session" = {
      idle-delay = mkUint32 0;
    };

    "org/gnome/desktop/wm/keybindings" = {
      switch-applications = ["<Super>Tab"];
      switch-applications-backward = ["<Shift><Super>Tab"];
      switch-group = ["<Alt>grave"];
      switch-group-backward = ["<Shift><Alt>grave"];
      switch-windows = ["<Alt>Tab"];
      switch-windows-backward = ["<Shift><Alt>Tab"];
    };

    "org/gnome/evolution-data-server" = {
      migrated = true;
    };

    "org/gnome/mutter" = {
      attach-modal-dialogs = true;
      dynamic-workspaces = true;
      edge-tiling = true;
      focus-change-on-pointer-rest = true;
      overlay-key = "Super_L";
      workspaces-only-on-primary = true;
    };

    "org/gnome/nautilus/preferences" = {
      default-folder-viewer = "icon-view";
      migrated-gtk-settings = true;
      search-filter-time-type = "last_modified";
      search-view = "list-view";
    };

    "org/gnome/nautilus/window-state" = {
      initial-size = mkTuple [890 550];
      maximized = true;
    };

    "org/gnome/portal/filechooser/google-chrome" = {
      last-folder-path = "/home/nepjua/Downloads";
    };

    "org/gnome/settings-daemon/plugins/power" = {
      power-button-action = "hibernate";
      sleep-inactive-ac-type = "nothing";
    };

    "org/gnome/shell" = {
      command-history = ["r"];
      disable-user-extensions = false;
      disabled-extensions = ["extensions-sync@elhan.io" "apps-menu@gnome-shell-extensions.gcampax.github.com" "auto-move-windows@gnome-shell-extensions.gcampax.github.com" "launch-new-instance@gnome-shell-extensions.gcampax.github.com" "native-window-placement@gnome-shell-extensions.gcampax.github.com"];
      enabled-extensions = ["user-theme@gnome-shell-extensions.gcampax.github.com" "advanced-alt-tab@G-dH.github.com" "quick-settings-tweaks@qwreey" "appindicatorsupport@rgcjonas.gmail.com"];
      favorite-apps = ["org.gnome.Geary.desktop" "org.gnome.Calendar.desktop" "org.gnome.Music.desktop" "org.gnome.Photos.desktop" "org.gnome.Nautilus.desktop"];
      welcome-dialog-last-shown-version = "43.2";
    };

    "org/gnome/shell/extensions/advanced-alt-tab-window-switcher" = {
      app-switcher-popup-icon-size = 96;
      app-switcher-popup-results-limit = 11;
      app-switcher-popup-search-pref-running = true;
      app-switcher-popup-sorting = 2;
      app-switcher-popup-titles = true;
      enable-super = true;
      hot-edge-mode = 1;
      hot-edge-monitor = 1;
      hot-edge-position = 2;
      super-double-press-action = 3;
      super-key-mode = 3;
      switcher-popup-monitor = 3;
      switcher-popup-position = 2;
      switcher-popup-preview-selected = 3;
      win-switcher-popup-order = 2;
      win-switcher-popup-search-all = true;
      win-switcher-popup-search-apps = true;
    };

    "org/gnome/shell/extensions/quick-settings-tweaks" = {
      list-buttons = "[{\"name\":\"SystemItem\",\"title\":null,\"visible\":true},{\"name\":\"OutputStreamSlider\",\"title\":null,\"visible\":true},{\"name\":\"InputStreamSlider\",\"title\":null,\"visible\":false},{\"name\":\"St_BoxLayout\",\"title\":null,\"visible\":true},{\"name\":\"BrightnessItem\",\"title\":null,\"visible\":false},{\"name\":\"NMWiredToggle\",\"title\":\"Wired\",\"visible\":true},{\"name\":\"NMWirelessToggle\",\"title\":\"Wi-Fi\",\"visible\":true},{\"name\":\"NMModemToggle\",\"title\":null,\"visible\":false},{\"name\":\"NMBluetoothToggle\",\"title\":null,\"visible\":false},{\"name\":\"NMVpnToggle\",\"title\":null,\"visible\":false},{\"name\":\"BluetoothToggle\",\"title\":\"Bluetooth\",\"visible\":true},{\"name\":\"PowerProfilesToggle\",\"title\":\"Power Mode\",\"visible\":true},{\"name\":\"NightLightToggle\",\"title\":\"Night Light\",\"visible\":true},{\"name\":\"DarkModeToggle\",\"title\":\"Dark Style\",\"visible\":true},{\"name\":\"KeyboardBrightnessToggle\",\"title\":\"Keyboard\",\"visible\":false},{\"name\":\"RfkillToggle\",\"title\":\"Airplane Mode\",\"visible\":false},{\"name\":\"RotationToggle\",\"title\":\"Auto Rotate\",\"visible\":false},{\"name\":\"DndQuickToggle\",\"title\":\"Do Not Disturb\",\"visible\":true},{\"name\":\"BackgroundAppsToggle\",\"title\":\"No Background Apps\",\"visible\":false},{\"name\":\"MediaSection\",\"title\":null,\"visible\":false},{\"name\":\"Notifications\",\"title\":null,\"visible\":false}]";
    };

    "org/gnome/shell/extensions/user-theme" = {
      name = "";
    };

    "org/gnome/shell/world-clocks" = {
      locations = [];
    };

    "org/gnome/software" = {
      check-timestamp = mkInt64 1713067111;
      first-run = false;
      flatpak-purge-timestamp = mkInt64 1713059851;
    };

    "org/gnome/tweaks" = {
      show-extensions-notice = false;
    };

    "org/gtk/gtk4/settings/file-chooser" = {
      date-format = "regular";
      location-mode = "path-bar";
      show-hidden = false;
      show-size-column = true;
      show-type-column = true;
      sidebar-width = 140;
      sort-column = "name";
      sort-directories-first = true;
      sort-order = "ascending";
      type-format = "category";
      view-type = "list";
      window-size = mkTuple [955 372];
    };

    "org/gtk/settings/file-chooser" = {
      date-format = "regular";
      location-mode = "path-bar";
      show-hidden = false;
      show-size-column = true;
      show-type-column = true;
      sidebar-width = 177;
      sort-column = "name";
      sort-directories-first = false;
      sort-order = "ascending";
      type-format = "category";
      window-position = mkTuple [2780 71];
      window-size = mkTuple [1719 1289];
    };

    "org/virt-manager/virt-manager" = {
      manager-window-height = 550;
      manager-window-width = 550;
    };

    "org/virt-manager/virt-manager/vmlist-fields" = {
      disk-usage = false;
      network-traffic = false;
    };
  };
}
