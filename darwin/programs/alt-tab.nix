{
  config,
  pkgs,
  ...
}: {
  homebrew.casks = [
    "alt-tab"
  ];

  system.defaults.menuExtraClock.ShowDayOfWeek = true;
  system.defaults.CustomUserPreferences = {
    "com.lwouis.alt-tab-macos" = {
      cursorFollowFocusEnabled = "false";
      holdShortcut = builtins.fromJSON "\"\\u2318\"";
      holdShortcut2 = builtins.fromJSON "\"\\u2318\"";
      mouseHoverEnabled = "true";
      hideWindowlessApps = "true";
      nextWindowShortcut3 = builtins.fromJSON "\"\\u21e5\"";
      screensToShow = 1;
      showFullscreenWindows = 1;
      showHiddenWindows = 1;
      showMinimizedWindows = 1;
      showOnScreen = 1;
      spacesToShow = 1;
      updatePolicy = 1;
    };
  };
}
