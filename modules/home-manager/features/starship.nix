{ ... }:
{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    enableFishIntegration = true;

    settings = {
      git_branch = {
        truncation_length = 24;
      };

      docker_context = {
        disabled = true;
      };
      
      shell = {
        disabled = false;
        fish_indicator = "󰈺 ";
        powershell_indicator = "_";
        bash_indicator = "_";
        zsh_indicator = "_";
        unknown_indicator = "mystery shell";
      };
    };
  };
}
