{ pkgs, ... }: {
  home.shellAliases = {
    ssh = "ssh.exe";
    ssh-add = "ssh-add.exe";
    ssh-keygen = "ssh-keygen.exe";

    telepresence = "telepresence.exe";
  };
}
