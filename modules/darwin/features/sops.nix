{ config, lib, ... }:
{
  # Basic sops configuration for darwin
  sops = {
    # Point to the main encrypted file in the repo root
    defaultSopsFile = ../../../.main.enc.yaml;
    defaultSopsFormat = "yaml";

    # Use the fixed global path where our CLI tool puts the key
    # Make it dynamic to work with any username
    age.keyFile = "${builtins.getEnv "HOME"}/.config/sops/age-key.txt";

    # Explicitly disable SSH to prevent it from trying to read host keys
    gnupg.sshKeyPaths = [ ];
  };
}
