{
  config,
  pkgs,
  ...
}: {
  homebrew.brews = [
    "cloudflared"
  ];

  homebrew.casks = [
    "anydesk"
    "cloudflare-warp"
    "microsoft-office"
    "obsidian"
    "parsec"
    "qbittorrent"
    "copyq"
    "slack"
    "steam"
    "teamviewer"
    "zoom"
    "warp"
    "mullvadvpn"
    "discord"
    "mtmr"
  ];
}
