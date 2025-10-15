{ pkgs }:

pkgs.stdenv.mkDerivation {
  pname = "oh-my-tmux";
  version = "2025-01-15";

  src = pkgs.fetchFromGitHub {
    owner = "gpakosz";
    repo = ".tmux";
    rev = "master";
    sha256 = "sha256-XXiyPSvrrtZgQ1IN797O1vgZDkwppKImgL+OQE507Fs=";
  };

  installPhase = ''
    mkdir -p $out
    cp .tmux.conf $out/tmux.conf
    cp .tmux.conf.local $out/tmux.conf.local
  '';

  meta = with pkgs.lib; {
    description = "Oh my tmux! My self-contained, pretty & versatile tmux configuration";
    homepage = "https://github.com/gpakosz/.tmux";
    license = with licenses; [
      mit
      wtfpl
    ];
    platforms = platforms.unix;
  };
}
