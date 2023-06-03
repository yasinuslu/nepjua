
{ inputs, lib, config, pkgs, colors, ... }: {
  home.packages = with pkgs; [
    # Command Line
    wget
    tldr
    parsec-bin
    jq
    lsd
    bat
    fd
    starship
    tmux
    vim
    nodejs
    yarn
    nodePackages.pnpm
    python3Minimal
    direnv
  ];

  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;

    settings = {
  add_newline = false;
  format = lib.concatStrings [
    "$line_break"
    "$package"
    "$line_break"
    "$character"
  ];
  scan_timeout = 10;
  character = {
    success_symbol = "➜";
    error_symbol = "➜";
  };
};
  };

  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
    enableBashIntegration = true;

    fileWidgetCommand = ''
      fd --type f --strip-cwd-prefix --hidden --follow --exclude .git
    '';
  };

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };
}
