{ ... }:
{
  # Touch ID for sudo, the update-safe way (manages /etc/pam.d/sudo_local so
  # macOS updates don't wipe it). `reattach` makes it work inside tmux too.
  # Purely additive: it adds a biometric method to interactive sudo prompts and
  # changes nothing about non-interactive sudo.
  #
  # DO NOT add `Defaults timestamp_type=global` here. It re-keys sudo's
  # credential cache from per-tty to per-user, which breaks Homebrew's
  # activation sudo. The Justfile `switch` recipe handles the Homebrew sudo
  # problem with a scoped, auto-removed NOPASSWD instead.
  security.pam.services.sudo_local = {
    enable = true;
    touchIdAuth = true;
    reattach = true;
  };
}
