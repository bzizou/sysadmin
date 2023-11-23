let
  # Pinned nixpkgs, deterministic.
  pkgs = import (fetchTarball("https://github.com/NixOS/nixpkgs/archive/dc7b3febf8d862328d8704de5c8437d2df442c76.tar.gz")) {};

  # Rolling updates, not deterministic.
  # pkgs = import (fetchTarball("channel:nixpkgs-unstable")) {};
in pkgs.mkShell {
  buildInputs = [ pkgs.cargo pkgs.rustc ];
}
