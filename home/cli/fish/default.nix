{
  lib,
  pkgs,
  ...
}: {
  programs.fish = {
    enable = true;
    plugins = [
      {
        name = "fisher";
        src = pkgs.fetchFromGitHub {
          owner = "jorgebucaran";
          repo = "fisher";
          rev = "master";
          sha256 = "sha256-28QW/WTLckR4lEfHv6dSotwkAKpNJFCShxmKFGQQ1Ew=";
        };
      }
      {
        name = "edc-bass";
        src = pkgs.fetchFromGitHub {
          owner = "edc";
          repo = "bass";
          rev = "master";
          sha256 = "sha256-zon5yBcCvL99L2Q5Cf++dfILvkwTezqWpkFUGIoD8Wc=";
        };
      }
      {
        name = "barnybug-docker-fish-completion";
        src = pkgs.fetchFromGitHub {
          owner = "barnybug";
          repo = "docker-fish-completion";
          rev = "master";
          sha256 = "sha256-2vwJLIeexu/4E05YlQoCf1udIrJtZO2VHHdBi6TKB1A=";
        };
      }
      {
        name = "jorgebucaran-fishopts";
        src = pkgs.fetchFromGitHub {
          owner = "jorgebucaran";
          repo = "fishopts";
          rev = "master";
          sha256 = "sha256-9hRFBmjrCgIUNHuOJZvOufyLsfreJfkeS6XDcCPesvw=";
        };
      }
      {
        name = "jorgebucaran-fish-menu";
        src = pkgs.fetchFromGitHub {
          owner = "jorgebucaran";
          repo = "fish-menu";
          rev = "master";
          sha256 = "sha256-qt3t1iKRRNuiLWiVoiAYOu+9E7jsyECyIqZJ/oRIT1A=";
        };
      }
      {
        name = "oh-my-fish-plugin-node-binpath";
        src = pkgs.fetchFromGitHub {
          owner = "oh-my-fish";
          repo = "plugin-node-binpath";
          rev = "master";
          sha256 = "sha256-Hkm9dhTC9lf2sviTIEBa56nayHgNVg8NOIvYg6EslH0=";
        };
      }
      {
        name = "oh-my-fish-plugin-osx"; # FIXME: Move this into a newly created osx-specific configuration
        src = pkgs.fetchFromGitHub {
          owner = "oh-my-fish";
          repo = "plugin-osx";
          rev = "master";
          sha256 = "sha256-jSUIk3ewM6QnfoAtp16l96N1TlX6vR0d99dvEH53Xgw=";
        };
      }
      {
        name = "jhillyerd-plugin-git";
        src = pkgs.fetchFromGitHub {
          owner = "jhillyerd";
          repo = "plugin-git";
          rev = "master";
          sha256 = "sha256-efKPbsXxjHm1wVWPJCV8teG4DgZN5dshEzX8PWuhKo4=";
        };
      }
      {
        name = "evanlucas-fish-kubectl-completions";
        src = pkgs.fetchFromGitHub {
          owner = "evanlucas";
          repo = "fish-kubectl-completions";
          rev = "master";
          sha256 = "sha256-OYiYTW+g71vD9NWOcX1i2/TaQfAg+c2dJZ5ohwWSDCc=";
        };
      }
      {
        name = "nepjua";
        src = ./fish-plugin-nepjua;
      }
    ];
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    enableFishIntegration = true;

    settings = {
      git_branch = {
        truncation_length = 24;
      };
    };
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
