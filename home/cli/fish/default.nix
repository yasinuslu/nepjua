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
          rev = "4.4.4";
          sha256 = "sha256-28QW/WTLckR4lEfHv6dSotwkAKpNJFCShxmKFGQQ1Ew=";
        };
      }
      {
        name = "edc-bass";
        src = pkgs.fetchFromGitHub {
          owner = "edc";
          repo = "bass";
          rev = "79b62958ecf4e87334f24d6743e5766475bcf4d0";
          sha256 = "sha256-3d/qL+hovNA4VMWZ0n1L+dSM1lcz7P5CQJyy+/8exTc=";
        };
      }
      {
        name = "jorgebucaran-fishopts";
        src = pkgs.fetchFromGitHub {
          owner = "jorgebucaran";
          repo = "fishopts";
          rev = "4b74206725c3e11d739675dc2bb84c77d893e901";
          sha256 = "sha256-9hRFBmjrCgIUNHuOJZvOufyLsfreJfkeS6XDcCPesvw=";
        };
      }
      {
        name = "jorgebucaran-autopair.fish";
        src = pkgs.fetchFromGitHub {
          owner = "jorgebucaran";
          repo = "autopair.fish";
          rev = "4d1752ff5b39819ab58d7337c69220342e9de0e2";
          sha256 = "sha256-qt3t1iKRRNuiLWiVoiAYOu+9E7jsyECyIqZJ/oRIT1A=";
        };
      }
      {
        name = "oh-my-fish-plugin-node-binpath";
        src = pkgs.fetchFromGitHub {
          owner = "oh-my-fish";
          repo = "plugin-node-binpath";
          rev = "70ecbe7be606b1b26bfd1a11e074bc92fe65550c";
          sha256 = "sha256-Hkm9dhTC9lf2sviTIEBa56nayHgNVg8NOIvYg6EslH0=";
        };
      }
      # {
      #   name = "oh-my-fish-plugin-osx"; # FIXME: Move this into a newly created osx-specific configuration
      #   src = pkgs.fetchFromGitHub {
      #     owner = "oh-my-fish";
      #     repo = "plugin-osx";
      #     rev = "master";
      #     sha256 = "sha256-jSUIk3ewM6QnfoAtp16l96N1TlX6vR0d99dvEH53Xgw=";
      #   };
      # }
      {
        name = "jhillyerd-plugin-git";
        src = pkgs.fetchFromGitHub {
          owner = "jhillyerd";
          repo = "plugin-git";
          rev = "c2b38f53f0b04bc67f9a0fa3d583bafb3f558718";
          sha256 = "sha256-efKPbsXxjHm1wVWPJCV8teG4DgZN5dshEzX8PWuhKo4=";
        };
      }
      {
        name = "evanlucas-fish-kubectl-completions";
        src = pkgs.fetchFromGitHub {
          owner = "evanlucas";
          repo = "fish-kubectl-completions";
          rev = "ced676392575d618d8b80b3895cdc3159be3f628";
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
