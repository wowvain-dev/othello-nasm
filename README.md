### Othello in NASM

#### Prerequisites
-  Nix package manager or `ncurses` pre-installed
-  Linux which supports ELF64 binary type

#### Running

THE GAME MUST BE RAN IN A PRETTY BIG TERMINAL WINDOW, I RECOMMEND HAVING IT FULLSCREEN

THE GAME WILL NOT TAKE INPUT PROPERLY IF THE FIRST RENDER ISN'T FULLY FINISHED (window too small)

 ##### With Nix installed
1. `nix-shell env.nix`
2. `make`
3. `./othello`

##### Without Nix
1. I have included my version of the `libncurses.so` file and set up the Makefile so that it automatically uses it. It might work out of the box, otherwise install ncurses with your own package manager.
2. `make`
3. `./othello`


