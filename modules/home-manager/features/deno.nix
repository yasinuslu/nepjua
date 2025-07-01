{ pkgs, ... }:
{
  home.packages = with pkgs; [
    deno
  ];

  myHomeManager.paths = [ "$HOME/.deno/bin" ];

  home.sessionVariables = {
    DENO_TLS_CA_STORE = "system";
  };
}
