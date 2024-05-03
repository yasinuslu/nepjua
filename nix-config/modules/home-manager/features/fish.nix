{pkgs, ...}: let taskCompletion = ''
set GO_TASK_PROGNAME task

function __task_get_tasks --description "Prints all available tasks with their description"
  # Read the list of tasks (and potential errors)
  $GO_TASK_PROGNAME --list-all 2>&1 | read -lz rawOutput

  # Return on non-zero exit code (for cases when there is no Taskfile found or etc.)
  if test $status -ne 0
    return
  end

  # Grab names and descriptions (if any) of the tasks
  set -l output (echo $rawOutput | sed -e '1d; s/\* \(.*\):\s*\(.*\)\s*(aliases.*/\1\t\2/' -e 's/\* \(.*\):\s*\(.*\)/\1\t\2/'| string split0)
  if test $output
    echo $output
  end
end

complete -c $GO_TASK_PROGNAME -d 'Runs the specified task(s). Falls back to the "default" task if no task name was specified, or lists all tasks if an unknown task name was
specified.' -xa "(__task_get_tasks)"

complete -c $GO_TASK_PROGNAME -s c -l color     -d 'colored output (default true)'
complete -c $GO_TASK_PROGNAME -s d -l dir       -d 'sets directory of execution'
complete -c $GO_TASK_PROGNAME      -l dry       -d 'compiles and prints tasks in the order that they would be run, without executing them'
complete -c $GO_TASK_PROGNAME -s f -l force     -d 'forces execution even when the task is up-to-date'
complete -c $GO_TASK_PROGNAME -s h -l help      -d 'shows Task usage'
complete -c $GO_TASK_PROGNAME -s i -l init      -d 'creates a new Taskfile.yml in the current folder'
complete -c $GO_TASK_PROGNAME -s l -l list      -d 'lists tasks with description of current Taskfile'
complete -c $GO_TASK_PROGNAME -s o -l output    -d 'sets output style: [interleaved|group|prefixed]' -xa "interleaved group prefixed"
complete -c $GO_TASK_PROGNAME -s p -l parallel  -d 'executes tasks provided on command line in parallel'
complete -c $GO_TASK_PROGNAME -s s -l silent    -d 'disables echoing'
complete -c $GO_TASK_PROGNAME      -l status    -d 'exits with non-zero exit code if any of the given tasks is not up-to-date'
complete -c $GO_TASK_PROGNAME      -l summary   -d 'show summary about a task'
complete -c $GO_TASK_PROGNAME -s t -l taskfile  -d 'choose which Taskfile to run. Defaults to "Taskfile.yml"'
complete -c $GO_TASK_PROGNAME -s v -l verbose   -d 'enables verbose mode'
complete -c $GO_TASK_PROGNAME      -l version   -d 'show Task version'
complete -c $GO_TASK_PROGNAME -s w -l watch     -d 'enables watch of the given task'
''; in {
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
      {
        name = "oh-my-fish-plugin-osx"; # FIXME: Move this into a newly created osx-specific configuration
        src = pkgs.fetchFromGitHub {
          owner = "oh-my-fish";
          repo = "plugin-osx";
          rev = "master";
          sha256 = "sha256-jSUIk3ewM6QnfoAtp16l96N1TlX6vR0d99dvEH53Xgw=";
        };
      }
      # (lib.mkIf (userConfig.system == "aarch64-darwin") {
      #   name = "oh-my-fish-plugin-osx"; # FIXME: Move this into a newly created osx-specific configuration
      #   src = pkgs.fetchFromGitHub {
      #     owner = "oh-my-fish";
      #     repo = "plugin-osx";
      #     rev = "master";
      #     sha256 = "sha256-jSUIk3ewM6QnfoAtp16l96N1TlX6vR0d99dvEH53Xgw=";
      #   };
      # })
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
    ];

    shellAliases = {
      lsl = "command ls --color";
      ls = "lsd";
    };

    shellAbbrs = {
      cls = "clear; echo 'Shell cleared'";
      gcom = "git checkout (git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')";
      gcd = "cd (git rev-parse --show-toplevel)";
      d = "docker";
      doc = "docker compose";
      docp = "docker compose -f docker-compose.yml -f docker-compose.prod.yml";
      docd = "docker compose -f docker-compose.yml -f docker-compose.dev.yml";
      k = "kubectl";
      mk = "microk8s.kubectl";
      md = "microk8s.docker";
      sk = "skaffold";
      df = "df -x'squashfs'";
    };

    functions = {
      git-remove-branches-except = {
        argumentNames = ["branches"];
        description = "Remove all git branches except the specified ones";
        body = ''
          if test -z "$branches"
            git branch | grep -v main | xargs git branch -D
          else
            set -l branch_regex (string join '|' $branches)
            git branch | grep -vE "main|$branch_regex" | xargs git branch -D
          end
        '';
      };

      git-local-upstream-exec = {
        description = "Execute given command in an upstream that is defined via local filesystem";
        body = ''
          set current_dir (pwd)
          set upstream (git config --local --get remote.origin.url | sed -e 's/.*\/\([^ ]*\/[^.]*\)\.git/\1/')
          cd $upstream
          eval $argv
          cd $current_dir
        '';
      };

      git-with-all-upstream-exec = {
        description = "Execute given command both in current git and upstream";
        body = ''
          git-local-upstream-exec $argv
          eval $argv
        '';
      };
    };

    shellInitLast = ''
      if type -q code-insiders
        set -xg EDITOR "code-insiders --wait"
      else if type -q code
        set -xg EDITOR "code --wait"
      else if type -q subl
        set -xg EDITOR "subl --wait"
      end

      if type -q gpg
        set -xg GPG_TTY (tty)
      end

      # For fish subshells, add to ~/.config/fish/config.fish.
      if status is-interactive
        printf '\eP$f{"hook": "SourcedRcFileForWarp", "value": { "shell": "fish"}}\x9c'

        ${taskCompletion}
      end
    '';
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
      docker_context = {
        disabled = true;
      };
    };
  };

  myHomeManager.paths = ["$HOME/.local/bin"];
}
