{...}: {
  homebrew = {
    onActivation = {
      cleanup = "zap";
      autoUpdate = true;
      upgrade = true;
    };
    taps = [
      "gromgit/fuse"
      "hashicorp/tap"
      "homebrew/cask"
      "homebrew/core"
      "metalbear-co/mirrord"
    ];
    enable = true;
    brews = [
      "bfg"
      "cloudflared"
      "ffmpeg"
      "gh"
      "git-lfs"
      "gromgit/fuse/sshfs-mac"
      "hashicorp/tap/vault"
      "imagemagick"
      "lazygit"
      "metalbear-co/mirrord/mirrord"
      "ncdu"
      "openjdk"
      "telnet"
      "tesseract"
      "tig"
    ];
    casks = [
      "1password-cli"
      "1password"
      "alt-tab"
      "anydesk"
      "cloudflare-warp"
      "cursor"
      "dbeaver-community"
      "discord"
      "gitkraken-cli"
      "gitkraken"
      "google-chrome"
      "hoppscotch"
      "insomnia"
      "lens"
      "logseq"
      "macfuse"
      "macfuse"
      "microsoft-auto-update"
      "microsoft-edge"
      "microsoft-office"
      "mtmr"
      "mullvadvpn"
      "notion"
      "obsidian"
      "parsec"
      "qbittorrent"
      "rectangle"
      "rustdesk"
      "slack"
      "spotify"
      "steam"
      "teamviewer"
      "visual-studio-code"
      "vlc"
      "warp"
      "whatsapp"
      "zed"
      "zen-browser"
      "zoom"
      # "background-music"
    ];
  };
}
