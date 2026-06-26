{ ... }:
{
  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
    enableNushellIntegration = true;

    # Default commands: `z <query>` jumps to the best-matching dir, `zi <query>` opens an
    # interactive fzf picker (fzf is already provided by features/fzf.nix). `cd` is left as-is.
    # To have zoxide take over `cd` entirely, set: options = [ "--cmd cd" ];
  };
}
