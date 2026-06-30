{ ... }:
{
  homebrew.taps = [
    "hamed-elfayome/claude-usage"
  ];

  homebrew.brews = [
    "cloudflared"
  ];

  homebrew.casks = [
    "anydesk"
    "parsec"
    "qbittorrent"
    "slack"
    "steam"
    "zoom"
    "cloudflare-warp"
    "discord"
    "gitkraken"
    "microsoft-auto-update"
    "rustdesk"
    "ollama-app"
    "crossover"
    "utm" # Apple Virtualization VMs (Windows 11 ARM, e.g. testing the zentab windows app)
    "lens"
    "mullvad-vpn"
    "antigravity"
    "claude"
    "claude-usage-tracker"
    "maccy"
  ];
}
