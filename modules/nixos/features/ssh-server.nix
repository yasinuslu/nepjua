{ pkgs, ... }:
let
  ssh-command-handler = pkgs.writeScriptBin "ssh-command-handler" ''
    #!/usr/bin/env bash
    if [ -z "$SSH_ORIGINAL_COMMAND" ]; then
      exec fish -l
    else
      exec bash -c "$SSH_ORIGINAL_COMMAND"
    fi
  '';
in
{
  environment.systemPackages = [ ssh-command-handler ];

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
        ForceCommand /run/current-system/sw/bin/ssh-command-handler
    '';
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAJdpt9EGv3VZwkxRUP0M90kVkkOCtC+huewLt6NJhKg"
  ];
}
