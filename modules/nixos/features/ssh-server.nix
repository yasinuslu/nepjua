{ ... }:
{
  services.openssh = {
    enable = true;
    allowSFTP = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = true;
      PubkeyAuthentication = true;
    };
    extraConfig = ''
      Match All
        PermitTTY yes
        ForceCommand if [ -z "$SSH_ORIGINAL_COMMAND" ]; then fish -l; else eval "$SSH_ORIGINAL_COMMAND"; fi
    '';
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAJdpt9EGv3VZwkxRUP0M90kVkkOCtC+huewLt6NJhKg"
  ];
}
