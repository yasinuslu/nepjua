{
  config,
  pkgs,
  ...
}: {
  homebrew = {
    onActivation = {
      cleanup = "zap";
      autoUpdate = true;
      upgrade = true;
    };
    taps = [
      "hashicorp/tap"
    ];
    enable = true;
    brews = [
      "openjdk"
      "bfg"
      "cloudflared"
      "tesseract"
      "ffmpeg"
      "gh"
      "imagemagick"
      "lazygit"
      "ncdu"
      "telnet"
      "tig"
      "hashicorp/tap/vault"
      "colima"
      "docker"
      "docker-compose"
    ];
    casks = [
      "1password"
      "1password-cli"
      "alt-tab"
      "copyq"
      "dbeaver-community"
      "discord"
      "google-chrome"
      "google-chrome-canary"
      "hiddenbar"
      "iterm2"
      "microsoft-auto-update"
      "microsoft-edge"
      "notion"
      "rectangle"
      "visual-studio-code"
      "vlc"
      "bettermouse"
    ];
  };
}
