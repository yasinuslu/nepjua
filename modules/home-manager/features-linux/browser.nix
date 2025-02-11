{ pkgs, ... }:
{
  home.packages =
    with pkgs;
    [
      chromium
      firefox
      browsers
    ]
    ++ (
      if pkgs.stdenv.system == "x86_64-linux" then
        [
          google-chrome
          microsoft-edge
        ]
      else
        [ ]
    );

  xdg.mimeApps.defaultApplications = {
    "text/html" = [ "microsoft-edge.desktop" ];
    "text/xml" = [ "microsoft-edge.desktop" ];
    "x-scheme-handler/http" = [ "microsoft-edge.desktop" ];
    "x-scheme-handler/https" = [ "microsoft-edge.desktop" ];
  };

  environment.sessionVariables = {
    BROWSER = "microsoft-edge";
  };
}
