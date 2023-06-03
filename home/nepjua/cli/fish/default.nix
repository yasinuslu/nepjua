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
          sha256 = "sha256-uWtEDpOrfQNGpS56WdoV13ggt4ESdsdM4gtPCcDpJyM=";
        };
      }
      {
        name = "edc-bass";
        src = pkgs.fetchFromGitHub {
          owner = "edc";
          repo = "bass";
          rev = "master";
          sha256 = "sha256-uWtEDpOrfQNGpS56WdoV13ggt4ESdsdM4gtPCcDpJyM=";
        };
      }
      {
        name = "barnybug-docker-fish-completion";
        src = pkgs.fetchFromGitHub {
          owner = "barnybug";
          repo = "docker-fish-completion";
          rev = "master";
          sha256 = "sha256-uWtEDpOrfQNGpS56WdoV13ggt4ESdsdM4gtPCcDpJyM=";
        };
      }
      {
        name = "jethrokuan-fzf";
        src = pkgs.fetchFromGitHub {
          owner = "jethrokuan";
          repo = "fzf";
          rev = "master";
          sha256 = "sha256-uWtEDpOrfQNGpS56WdoV13ggt4ESdsdM4gtPCcDpJyM=";
        };
      }
      {
        name = "jorgebucaran-fishopts";
        src = pkgs.fetchFromGitHub {
          owner = "jorgebucaran";
          repo = "fishopts";
          rev = "master";
          sha256 = "sha256-uWtEDpOrfQNGpS56WdoV13ggt4ESdsdM4gtPCcDpJyM=";
        };
      }
      {
        name = "jorgebucaran-fish-menu";
        src = pkgs.fetchFromGitHub {
          owner = "jorgebucaran";
          repo = "fish-menu";
          rev = "master";
          sha256 = "sha256-uWtEDpOrfQNGpS56WdoV13ggt4ESdsdM4gtPCcDpJyM=";
        };
      }
      {
        name = "oh-my-fish-plugin-node-binpath";
        src = pkgs.fetchFromGitHub {
          owner = "oh-my-fish";
          repo = "plugin-node-binpath";
          rev = "master";
          sha256 = "sha256-uWtEDpOrfQNGpS56WdoV13ggt4ESdsdM4gtPCcDpJyM=";
        };
      }
      {
        name = "oh-my-fish-plugin-osx";
        src = pkgs.fetchFromGitHub {
          owner = "oh-my-fish";
          repo = "plugin-osx";
          rev = "master";
          sha256 = "sha256-uWtEDpOrfQNGpS56WdoV13ggt4ESdsdM4gtPCcDpJyM=";
        };
      }
      {
        name = "oh-my-fish-theme-bobthefish";
        src = pkgs.fetchFromGitHub {
          owner = "oh-my-fish";
          repo = "theme-bobthefish";
          rev = "master";
          sha256 = "sha256-uWtEDpOrfQNGpS56WdoV13ggt4ESdsdM4gtPCcDpJyM=";
        };
      }
      {
        name = "jhillyerd-plugin-git";
        src = pkgs.fetchFromGitHub {
          owner = "jhillyerd";
          repo = "plugin-git";
          rev = "master";
          sha256 = "sha256-uWtEDpOrfQNGpS56WdoV13ggt4ESdsdM4gtPCcDpJyM=";
        };
      }
      {
        name = "evanlucas-fish-kubectl-completions";
        src = pkgs.fetchFromGitHub {
          owner = "evanlucas";
          repo = "fish-kubectl-completions";
          rev = "master";
          sha256 = "sha256-uWtEDpOrfQNGpS56WdoV13ggt4ESdsdM4gtPCcDpJyM=";
        };
      }
    ];
  };

  programs.starship = {
    enable = true;
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
