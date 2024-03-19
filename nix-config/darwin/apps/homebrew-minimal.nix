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
      "dbeaver-community"
      "google-chrome"
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
