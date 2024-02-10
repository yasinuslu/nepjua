{
  config,
  pkgs,
  ...
}: {
  homebrew = {
    enable = true;
    brews = [
      "gh"
      "1password-cli"
    ];
    casks = [
      "1password"
      "alt-tab"
      "anydesk"
      "bettermouse"
      "copyq"
      "discord"
      "google-chrome"
      "hiddenbar"
      "iterm2"
      "lunar"
      "microsoft-edge"
      "microsoft-office"
      "mullvadvpn"
      "notion"
      "obsidian"
      "parsec"
      "qbittorrent"
      "rancher"
      "rectangle"
      "slack"
      "spotify"
      "steam"
      "teamviewer"
      "visual-studio-code"
      "vlc"
      "whatsapp"
      "zoom"
      "karabiner-elements"
    ];
  };
}
