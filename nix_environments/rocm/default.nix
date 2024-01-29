let
  # Pinned nixpkgs, deterministic.
  pkgs = import (fetchTarball("https://github.com/NixOS/nixpkgs/archive/cb8d00f6c5a88644d38b8eb3f23c239cc120465d.tar.gz")) {};

in pkgs.mkShell {
  buildInputs = with pkgs; [ openmpi ucx rocmPackages.rocm-smi rocmPackages.clr cmake ];
}
