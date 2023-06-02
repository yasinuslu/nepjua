# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)

{ inputs, lib, config, pkgs, colors, ... }: {
  # You can import other home-manager modules here
  imports = [
    # If you want to use home-manager modules from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModule

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
    # ./kitty.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # If you want to use overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = (_: true);
    };
  };

  home = {
    username = "nepjua";
    homeDirectory = "/home/nepjua";
  };

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # Applications
    google-chrome
    microsoft-edge
    copyq
    qbittorrent
    vlc

    # Gnome
    gnome.gnome-tweaks
    guake
    gnomeExtensions.advanced-alttab-window-switcher
    gnomeExtensions.quick-settings-tweaker
    gnomeExtensions.appindicator

    # Command Line
    wget
    tldr
    parsec-bin

    # From previous dotfiles
    fish
    jq
    lsd
    bat
    fzf
    fd
    starship
    tmux
    vim
    nodejs
    yarn
    nodePackages.pnpm
    python3Minimal

    discord
    betterdiscordctl

    direnv
    slack
  ];

  programs.git = {
    enable = true;
    diff-so-fancy.enable = true;
  };

  programs.vscode = {
    enable = true;
  };

  programs.fish = {
    enable = true;
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

  services.gnome-keyring.enable = true;
  home.sessionVariables = {
    XDG_DATA_DIRS = "/var/lib/flatpak/exports/share:$HOME/share/flatpak/exports/share";
  };

  # Enable home-manager and git
  programs.home-manager.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "22.11";
}
