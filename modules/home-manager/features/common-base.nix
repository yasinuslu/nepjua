{
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    inputs.nix-colors.homeManagerModule
  ];

  programs.git = {
    enable = true;
    lfs.enable = true;
    diff-so-fancy.enable = true;
  };

  home.packages = with pkgs; [
    cachix
    nixd

    nixfmt-rfc-style
    nixpkgs-review

    wget
    tldr
    jq
    lsd
    starship
    vim
    lsof

    # Python
    btop
    dos2unix
    alejandra
    openssl
    rclone

    coreutils-full
    gnugrep
    findutils
    binutils
    file
  ];

  home.sessionVariables = {
    DIRENV_LOG_FORMAT = "";
    NIXPKGS_ALLOW_UNFREE = "1";
    LANG = "en_US.UTF-8";
    LC_MESSAGES = "en_US.UTF-8";
  };

  programs = {
    home-manager.enable = true;
    java.enable = true;
    direnv.enable = true;
    direnv.nix-direnv.enable = true;
    gh.enable = true;
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
