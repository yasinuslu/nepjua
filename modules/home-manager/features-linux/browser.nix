{pkgs, ...}: {
  home.packages = with pkgs; [
    google-chrome
    chromium
    firefox
    browsers
    microsoft-edge
  ];

  xdg.mimeApps.defaultApplications = {
    "text/html" = ["google-chrome.desktop"];
    "text/xml" = ["google-chrome.desktop"];
    "x-scheme-handler/http" = ["google-chrome.desktop"];
    "x-scheme-handler/https" = ["google-chrome.desktop"];
  };
}
