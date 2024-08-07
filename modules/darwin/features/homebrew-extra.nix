{...}: {
  homebrew.brews = [
    "cloudflared"
    "gromgit/fuse/sshfs-mac"
    "metalbear-co/mirrord/mirrord"
  ];

  homebrew.taps = [
    "gromgit/fuse"
    "metalbear-co/mirrord"
  ];

  homebrew.casks = [
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
