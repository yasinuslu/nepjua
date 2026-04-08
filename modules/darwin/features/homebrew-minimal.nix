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
      "cocoapods"
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
      "htop"
      "jeffreywildman/homebrew-virt-manager/virt-viewer"
      "sonar-scanner"
    ];
    casks = [
      "1password-cli"
      "1password"
      "alt-tab"
      # "background-music"
      "google-chrome"
      "notion"
      "bettermouse"
      "gitkraken-cli"
      "insomnia"
      "obsidian"
      "rectangle"
      "spotify"
      "visual-studio-code"
      "vlc"
      "whatsapp"
      "zed"
      "zen"
      "jordanbaird-ice@beta"
      "ghostty"
      "blender"
      "beyond-compare"
      "superwhisper"
      # "copyq"
      "blender"
    ];
  };
}
