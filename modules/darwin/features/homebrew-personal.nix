{ ... }:
{
  homebrew.taps = [
    "hamed-elfayome/claude-usage"
  ];

  homebrew.brews = [
    "cloudflared"
  ];

  homebrew.casks = [
    # For some reason, upgrading anydesk is failing even though I deleted it
    # "anydesk"
    "parsec"
    "qbittorrent"
    "slack"
    "steam"
    "teamviewer"
    "zoom"
    "cloudflare-warp"
    "blitz-gg"
    "discord"
    "gitkraken"
    "microsoft-auto-update"
    "microsoft-office"
    "rustdesk"
    "ollama-app"
    "crossover"
    # "mullvadvpn"
    "soundsource"
    "lens"
    "mullvad-vpn"
    "antigravity"
    "cursor"
    "claude-usage-tracker"
  ];
}
