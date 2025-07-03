{ config, lib, ... }:
{
  # Basic sops configuration for darwin
  sops = {
    # Default secret file path relative to the flake root
    defaultSopsFile = ../../../hosts/${config.networking.hostName}/secrets.enc.json;
    defaultSopsFormat = "json";

    # Use the standardized age key location
    age.keyFile = "/Users/nepjua/code/nepjua/.sops/age-key.txt";
  };
}
