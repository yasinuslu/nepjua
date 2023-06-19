{
  config,
  pkgs,
}: {
  homebrew.casks = [
    "alt-tab"
  ];

  system.defaults.CustomUserPreferences = {
    "com.lwouis.alt-tab-macos" = {
      MSAppCenter310AppCenterUserDefaultsMigratedKey = 1;
      MSAppCenter310CrashesUserDefaultsMigratedKey = 1;
      MSAppCenterAppDidReceiveMemoryWarning = 1;
      MSAppCenterInstallId = "F289D0C4-C703-4BB7-B755-17051D467E62";
      MSAppCenterNetworkRequestsAllowed = 0;
      # MSAppCenterPastDevices = {length = 1146, bytes = 0x62706c69 73743030 d4010203 04050607 ... 00000000 00000386 };
      # MSAppCenterSessionIdHistory = {length = 460, bytes = 0x62706c69 73743030 d4010203 04050607 ... 00000000 00000156 };
      # MSAppCenterUserIdHistory = {length = 455, bytes = 0x62706c69 73743030 d4010203 04050607 ... 00000000 00000151 };
      NSNavLastRootDirectory = "/Applications";
      NSNavPanelExpandedSizeForOpenMode = "{800, 448}";
      "NSWindow Frame NSNavPanelAutosaveName" = "464 459 800 448 0 0 1728 1079 ";
      SUHasLaunchedBefore = 1;
      SULastCheckTime = "2023-06-15 09:33:24 +0000";
      # blacklist = "[{\\"ignore\\":\\"0\\",\\"bundleIdentifier\\":\\"com.McAfee.McAfeeSafariHost\\",\\"hide\\":\\"1\\"},{\\"ignore\\":\\"0\\",\\"bundleIdentifier\\":\\"com.apple.finder\\",\\"hide\\":\\"2\\"},{\\"ignore\\":\\"2\\",\\"bundleIdentifier\\":\\"com.microsoft.rdc.macos\\",\\"hide\\":\\"0\\"},{\\"ignore\\":\\"2\\",\\"bundleIdentifier\\":\\"com.teamviewer.TeamViewer\\",\\"hide\\":\\"0\\"},{\\"ignore\\":\\"2\\",\\"bundleIdentifier\\":\\"org.virtualbox.app.VirtualBoxVM\\",\\"hide\\":\\"0\\"},{\\"ignore\\":\\"2\\",\\"bundleIdentifier\\":\\"com.parallels.\\",\\"hide\\":\\"0\\"},{\\"ignore\\":\\"2\\",\\"bundleIdentifier\\":\\"com.citrix.XenAppViewer\\",\\"hide\\":\\"0\\"},{\\"ignore\\":\\"2\\",\\"bundleIdentifier\\":\\"com.citrix.receiver.icaviewer.mac\\",\\"hide\\":\\"0\\"},{\\"ignore\\":\\"2\\",\\"bundleIdentifier\\":\\"com.nicesoftware.dcvviewer\\",\\"hide\\":\\"0\\"},{\\"ignore\\":\\"2\\",\\"bundleIdentifier\\":\\"com.vmware.fusion\\",\\"hide\\":\\"0\\"},{\\"ignore\\":\\"2\\",\\"bundleIdentifier\\":\\"com.apple.ScreenSharing\\",\\"hide\\":\\"0\\"},{\\"ignore\\":\\"0\\",\\"bundleIdentifier\\":\\"com.googlecode.iterm2\\",\\"hide\\":\\"2\\"}]";
      cursorFollowFocusEnabled = false;
      holdShortcut = "\\U2318";
      holdShortcut2 = "\\U2318";
      mouseHoverEnabled = true;
      nextWindowShortcut3 = "\\U21e5";
      preferencesVersion = "6.59.0";
      screensToShow = 1;
      showFullscreenWindows = 1;
      showHiddenWindows = 1;
      showMinimizedWindows = 1;
      showOnScreen = 1;
      spacesToShow = 1;
      updatePolicy = 1;
      windowMaxWidthInRow = 30;
    };
  };
}
