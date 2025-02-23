{ ... }:
{
  homebrew = {
    onActivation = {
      cleanup = "zap";
      autoUpdate = true;
      upgrade = true;
    };
    taps = [
      "hashicorp/tap"
      "jeffreywildman/homebrew-virt-manager"
    ];
    enable = true;
    brews = [
      "bfg"
      "ffmpeg"
      "gh"
      "git-lfs"
      "hashicorp/tap/vault"
      "imagemagick"
      "lazygit"
      "ncdu"
      "openjdk"
      "telnet"
      "tesseract"
      "tig"
      "jeffreywildman/homebrew-virt-manager/virt-viewer"
    ];
    casks = [
      "1password-cli"
      "1password"
      "alt-tab"
      "mos"
      # "background-music"
      "bettermouse"
      "cloudflare-warp"
      "cursor"
      "blitz-gg"
      "dbeaver-community"
      "discord"
      "gitkraken-cli"
      "gitkraken"
      "google-chrome"
      "hoppscotch"
      "insomnia"
      "logseq"
      "microsoft-auto-update"
      "microsoft-edge"
      "microsoft-office"
      "mtmr"
      "notion"
      "obsidian"
      "rectangle"
      "rustdesk"
      "spotify"
      "visual-studio-code"
      "vlc"
      "warp"
      "whatsapp"
      "zed"
      "zen-browser"
      "ollama"
      "crossover"
      "copyq"
    ];
  };
}
