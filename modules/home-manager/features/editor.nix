{pkgs, ...}: {
  home.sessionVariables = {
    EDITOR = "code --wait";
    CODE_EDITOR = "code --wait";
  };

  home.packages = [
    pkgs.writeScriptBin
    "code"
    ''
      cursor "$@"
    ''
  ];
}
