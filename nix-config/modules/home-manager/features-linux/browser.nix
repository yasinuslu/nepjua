{pkgs, ...}: {
  home.packages = with pkgs; [
    google-chrome
    microsoft-edge
  ];

  xdg.mimeApps.defaultApplications = {
    "text/html" = ["microsoft-edge.desktop"];
    "text/xml" = ["microsoft-edge.desktop"];
    "x-scheme-handler/http" = ["microsoft-edge.desktop"];
    "x-scheme-handler/https" = ["microsoft-edge.desktop"];
  };
}
