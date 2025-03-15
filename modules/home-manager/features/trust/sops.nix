{ pkgs, ... }:
{
  # Install SOPS
  home.packages = with pkgs; [
    sops
  ];

  # Create a basic SOPS configuration file
  home.file.".sops.yaml" = {
    text = ''
      # This is a basic SOPS configuration file
      # Customize it based on your needs

      creation_rules:
        - path_regex: secrets/.*\.yaml$
          # You can specify age public keys here
          # age: >-
          #   age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
          
          # Or GPG keys
          # pgp: >-
          #   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
          
          # Example with both:
          # age: >-
          #   age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
          # pgp: >-
          #   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    '';
  };

  # Create a directory for SOPS-encrypted secrets
  home.file."secrets/.keep" = {
    text = "";
    onChange = ''
      if [ ! -d "$HOME/secrets" ]; then
        mkdir -p "$HOME/secrets"
      fi
    '';
  };
}
