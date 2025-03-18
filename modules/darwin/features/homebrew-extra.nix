{ ... }:
{
  homebrew.taps = [
    "metalbear-co/mirrord"
  ];

  homebrew.brews = [
    "cloudflared"
    "metalbear-co/mirrord/mirrord"
  ];

  homebrew.casks = [
    "macfuse"
    "anydesk"
    "microsoft-office"
    "parsec"
    "qbittorrent"
    "slack"
    "steam"
    "teamviewer"
    "zoom"
    "cloudflare-warp"
    "cursor"
    "blitz-gg"
    "discord"
    "gitkraken"
    "microsoft-auto-update"
    "microsoft-office"
    "notion"
    "rustdesk"
    "ollama"
    "crossover"
    "logseq"
    # I'm not exactly sure why, but brew is not able to install mullvadvpn
    "mullvadvpn"
    "mtmr"
    "macfuse"
    "lens"
  ];
}
