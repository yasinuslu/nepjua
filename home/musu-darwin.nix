{inputs, pkgs, ...}: {
  # You can import other home-manager modules here
  imports = [
    # You can also split up your configuration and import pieces of it here:
    ./darwin.nix
  ];

  programs.git = {
    enable = true;
    userEmail = "msaiduslu@gmail.com";
    userName = "Muhammed Said Uslu";
  };
}
