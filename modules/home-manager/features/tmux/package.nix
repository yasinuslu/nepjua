{ pkgs }:

pkgs.stdenv.mkDerivation {
  pname = "oh-my-tmux";
  version = "2025-01-15";

  src = pkgs.fetchFromGitHub {
    owner = "gpakosz";
    repo = ".tmux";
    rev = "master";
    sha256 = "sha256-0yfcig5f81b25fc4ia1266ihjkr0grrnn49kvqb28qhbiz87bfk5";
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
