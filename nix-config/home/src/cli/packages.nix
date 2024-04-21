# Moved
{
  pkgs,
  inputs,
  ...
}: {
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
    lsof

    # Python
    python312

    btop

    dos2unix
  ];

  home.sessionVariables = {
    DIRENV_LOG_FORMAT = "";
  };
}
