{ pkgs, ... }:
{
  # Install age encryption tool
  home.packages = with pkgs; [
    age
    rage # Rust implementation of age with some extra features
  ];

  # Create directory for age keys
  home.file.".age/.keep" = {
    text = "";
    onChange = ''
      if [ ! -d "$HOME/.age" ]; then
        mkdir -p "$HOME/.age"
        chmod 700 "$HOME/.age"
      fi
    '';
  };
}
