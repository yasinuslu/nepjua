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
      "metalbear-co/mirrord"
      {
        name = "yasinuslu/cask";
        clone_target = "https://github.com/yasinuslu/homebrew-cask.git";
        force_auto_update = true;
      }
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
      "yasinuslu/cask/mullvadvpn"
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
