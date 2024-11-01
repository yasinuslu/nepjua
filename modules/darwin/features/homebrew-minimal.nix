{...}: {
  homebrew = {
    onActivation = {
      cleanup = "zap";
      autoUpdate = true;
      upgrade = true;
    };
    taps = [
      "hashicorp/tap"
      # "zen-browser/browser"
    ];
    enable = true;
    brews = [
      "openjdk"
      "bfg"
      "tesseract"
      "ffmpeg"
      "gh"
      "imagemagick"
      "lazygit"
      "ncdu"
      "telnet"
      "tig"
      "hashicorp/tap/vault"
      "git-lfs"
    ];
    casks = [
      "1password"
      "1password-cli"
      "alt-tab"
      "dbeaver-community"
      "google-chrome"
      "microsoft-auto-update"
      "microsoft-edge"
      "notion"
      "rectangle"
      "cursor"
      "vlc"
      "spotify"
      "whatsapp"
      "zed"
      "warp"
      "discord"
      "gitkraken-cli"
      "gitkraken"
      "logseq"
      "ollama"
      "obsidian"
      "cloudflare-warp"
      "hoppscotch"
      "insomnia"
    ];
  };
}
