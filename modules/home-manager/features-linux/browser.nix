{pkgs, ...}: {
  home.packages = with pkgs;
    [
      chromium
      firefox
      browsers
    ]
    ++ (
      if pkgs.stdenv.system == "x86_64-linux"
      then [google-chrome microsoft-edge]
      else []
    );

  xdg.mimeApps.defaultApplications = {
    "text/html" = ["google-chrome.desktop"];
    "text/xml" = ["google-chrome.desktop"];
    "x-scheme-handler/http" = ["google-chrome.desktop"];
    "x-scheme-handler/https" = ["google-chrome.desktop"];
  };
}
