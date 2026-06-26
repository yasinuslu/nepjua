{ ... }:
{
  homebrew = {
    onActivation = {
      cleanup = "zap";
      autoUpdate = true;
      upgrade = false;
    };
    taps = [
      "hashicorp/tap"
      "jeffreywildman/homebrew-virt-manager"
      "deskflow/tap"
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
      "snyk-cli"
      "rustup"
      "swiftlint" # Swift linting (used by the zentab project's bin/lint + CI)
      "xcbeautify" # readable xcodebuild output for Swift/macOS projects
      "xcode-build-server" # feeds SourceKit-LSP for editor (Zed) autocomplete on xcodeproj
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
      "spokenly"
      # "copyq"
      "blender"
      "deskflow/tap/deskflow"
      "podman-desktop"
    ];
  };
}
