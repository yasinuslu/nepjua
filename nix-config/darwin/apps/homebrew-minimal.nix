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
      "git-lfs"
    ];
    casks = [
      "1password"
      "1password-cli"
      "alt-tab"
      "dbeaver-community"
      "google-chrome"
      "iterm2"
      "microsoft-auto-update"
      "microsoft-edge"
      "notion"
      "rectangle"
      "visual-studio-code"
      "vlc"
      "bettermouse"
      "betterdisplay"
      "spotify"
      "whatsapp"
    ];
  };
}
