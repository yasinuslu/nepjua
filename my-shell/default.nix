{pkgs, ...}: {
  shell = {
    name = "default";
    buildInputs = with pkgs; [
      just
      python312
      python312Packages.pip
    ];
    shellHook = ''
      echo "Welcome in $name"
      export HF_HUB_ENABLE_HF_TRANSFER=1
      export PATH=$HOME/.local/bin:$PATH
      export PATH=$HOME/.console-ninja/.bin:$PATH
      export PATH=$HOME/.bun/bin:$PATH
    '';
  };
}
