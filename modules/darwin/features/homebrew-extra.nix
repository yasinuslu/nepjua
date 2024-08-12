{...}: {
  homebrew.taps = [
    "gromgit/fuse"
    "metalbear-co/mirrord"
  ];

  homebrew.brews = [
    "cloudflared"
    "gromgit/fuse/sshfs-mac"
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
    "mullvadvpn"
    "mtmr"
    "macfuse"
  ];
}
