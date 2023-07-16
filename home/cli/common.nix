{pkgs, ...}: {
  imports = [
    ./fish
    ./git
    ./fzf.nix
    ./tmux.nix
    ./node.nix
  ];

  home.packages = with pkgs; [
    nil
    nixpkgs-fmt

    wget
    tldr
    jq
    lsd
    bat
    starship
    vim

    # FIXME: Python area, should be in a separate file
    # Python
    python311Full

    btop
  ];

  home.sessionVariables = {
    DIRENV_LOG_FORMAT = "";
  };
}
