{ ... }:
{
  homebrew.taps = [ ];

  homebrew.brews = [
    "cloudflared"
  ];

  homebrew.casks = [
    "macfuse"
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
    "macfuse"
    "lens"
    "mullvad-vpn"
    "antigravity"
    "comet"
  ];
}
