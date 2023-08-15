{
  config,
  pkgs,
  ...
}: {
  homebrew = {
    enable = true;
    casks = [
      "google-chrome"
      "1password"
      "alt-tab"
      "iterm2"
      "microsoft-edge"
      "copyq"
      "visual-studio-code"
      "rectangle"
      "slack"
      "microsoft-office"
      "zoom"
      "whatsapp"
      "notion"
      "obsidian"
      "spotify"
      "steam"
      "vlc"
      "qbittorrent"
      "mullvadvpn"
      "parsec"
      "discord"
      "anydesk"
      "rancher"
      "teamviewer"
      "mos"
      "lunar"
      "hiddenbar"
    ];
  };
}
