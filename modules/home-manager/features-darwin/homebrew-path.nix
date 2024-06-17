{...}: {
  programs.zsh.initExtraFirst = ''
    __init_homebrew() {
      if [[ -e /opt/homebrew/bin/brew ]]; then
        eval $(/opt/homebrew/bin/brew shellenv)
      fi

      if [[ -e /usr/local/bin/brew ]]; then
        eval $(/usr/local/bin/brew shellenv)
      fi
    }

    __init_homebrew
  '';

  programs.bash.profileExtra = ''
    __init_homebrew() {
      if [[ -e /opt/homebrew/bin/brew ]]; then
        eval $(/opt/homebrew/bin/brew shellenv)
      fi

      if [[ -e /usr/local/bin/brew ]]; then
        eval $(/usr/local/bin/brew shellenv)
      fi
    }

    __init_homebrew
  '';

  programs.fish.loginShellInit = ''
    function __init_homebrew
      if test -e /opt/homebrew/bin/brew
        eval (/opt/homebrew/bin/brew shellenv)
      end

      if test -e /usr/local/bin/brew
        eval (/usr/local/bin/brew shellenv)
      end
    end

    __init_homebrew
  '';
}
