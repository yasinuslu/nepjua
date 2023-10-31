function __nepjua_common_init
  set -xg EDITOR vim

  __nepjua_docker_alias_init

  alias lsl "command ls --color"
  alias ls lsd
  alias cat bat
  alias pcat "bat --plain"

  abbr -a gcd "cd (git rev-parse --show-toplevel)"
  abbr -a gcom "git checkout (git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')"

  abbr -a cls clear

  set -xg IS_WSL (grep Microsoft /proc/sys/kernel/osrelease 2>/dev/null \
    | wc -l | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')

  set -xg NODEJS_CHECK_SIGNATURES no

  fish_add_path $HOME/.local/bin

  set -xg TERM xterm-256color
  set -xg BYOBU_BACKEND tmux

  set -xg theme_display_user yes
  set -xg theme_color_scheme terminal-dark
  set -xg theme_display_ruby no

  if test -d $HOME/.kube
    set -xg KUBECONFIG (echo $HOME/.kube/config* | sed -e "s/\ /:/g")
  end

  if [ "$IS_WSL" = "0" ]
    # we're in a non-wsl unix environment
    __nepjua_unix_init
  else
    # if we're in WSL
    __nepjua_wsl_init
  end


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

  if type -q yay
    alias yay "yay --color=always --noconfirm"
  end

  if test -d $HOME/.cargo/bin
    fish_add_path $HOME/.cargo/bin
  end

  if test -d $HOME/.cabal/bin
    fish_add_path $HOME/.cabal/bin
  end

  if test -d $HOME/.ghcup/bin
    fish_add_path $HOME/.ghcup/bin
  end

  if test -d $HOME/.config/op/plugins.sh
    source $HOME/.config/op/plugins.sh
  end

  if type -q starship
    starship init fish | source
  end

  if type -q react-native
    abbr --add rn 'react-native'
  end

  if test -d $PWD/vendor/bin
    fish_add_path $PWD/vendor/bin
  end

  # FIXME: Learn how to utilize this in home-manager
  if test -d /etc/nix
    set -xg NIXPKGS_ALLOW_UNFREE 1
  end

  function git-remove-branches-except --argument-names branches --description "Remove all git branches except the specified ones"
    if test -z "$branches"
      git branch | grep -v main | xargs git branch -D
    else
      set -l branch_regex (string join '|' $branches)
      git branch | grep -vE "main|$branch_regex" | xargs git branch -D
    end
  end

  function git-local-upstream-exec --description "Execute given command in an upstream that is defined via local filesystem"
    set current_dir (pwd)
    set upstream (git config --local --get remote.origin.url | sed -e 's/.*\/\([^ ]*\/[^.]*\)\.git/\1/')
    cd $upstream
    eval $argv
    cd $current_dir
  end

  function git-with-all-upstream-exec --description "Execute given command both in current git and upstream"
    git-local-upstream-exec $argv
    eval $argv
  end
end
