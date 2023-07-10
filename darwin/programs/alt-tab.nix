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
      blacklist = builtins.toJSON [
        {
          bundleIdentifier = "com.McAfee.McAfeeSafariHost";
          hide = "1";
          ignore = "0";
        }
        {
          bundleIdentifier = "com.apple.finder";
          hide = "2";
          ignore = "0";
        }
        {
          bundleIdentifier = "com.microsoft.rdc.macos";
          hide = "0";
          ignore = "2";
        }
        {
          bundleIdentifier = "com.teamviewer.TeamViewer";
          hide = "0";
          ignore = "2";
        }
        {
          bundleIdentifier = "org.virtualbox.app.VirtualBoxVM";
          hide = "0";
          ignore = "2";
        }
        {
          bundleIdentifier = "com.parallels.";
          hide = "0";
          ignore = "2";
        }
        {
          bundleIdentifier = "com.citrix.XenAppViewer";
          hide = "0";
          ignore = "2";
        }
        {
          bundleIdentifier = "com.citrix.receiver.icaviewer.mac";
          hide = "0";
          ignore = "2";
        }
        {
          bundleIdentifier = "com.nicesoftware.dcvviewer";
          hide = "0";
          ignore = "2";
        }
        {
          bundleIdentifier = "com.vmware.fusion";
          hide = "0";
          ignore = "2";
        }
        {
          bundleIdentifier = "com.apple.ScreenSharing";
          hide = "0";
          ignore = "2";
        }
        {
          bundleIdentifier = "com.googlecode.iterm2";
          hide = "2";
          ignore = "0";
        }
      ];
      cursorFollowFocusEnabled = "false";
      holdShortcut = builtins.fromJSON "\"\\u2318\"";
      holdShortcut2 = builtins.fromJSON "\"\\u2318\"";
      mouseHoverEnabled = "true";
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
