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

    # Test with the simple root-level value first
    secrets = {
      "test-value" = {
        key = "test-value";
        mode = "0400";
      };
    };
  };

  # Add to launchd for runtime verification (can be run manually)
  launchd.user.agents.sops-test = {
    script = ''
      echo "SOPS Test - Secret content:"
      cat ${config.sops.secrets."test-value".path}
      echo "SOPS test completed at $(date)"
    '';
    serviceConfig = {
      RunAtLoad = false; # Don't run automatically
      StandardOutPath = "/tmp/sops-test.log";
      StandardErrorPath = "/tmp/sops-test.log";
    };
  };
}
