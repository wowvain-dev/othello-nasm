with import <nixpkgs> {};

stdenv.mkDerivation {
  name = "othello-game";

  buildInputs = with pkgs; [
    nasm 
    gcc

    ncurses
  ];
}
