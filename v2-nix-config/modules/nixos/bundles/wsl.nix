{...}: {
  wsl.enable = true;
  wsl.defaultUser = "nepjua";
  wsl.nativeSystemd = true;

  environment.shellAliases = {
    ssh = "ssh.exe";
    ssh-add = "ssh-add.exe";
  };
}
