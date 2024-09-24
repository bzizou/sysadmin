{
  description = "Rmpi flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
    mpi-src = {
      url = "https://download.open-mpi.org/release/open-mpi/v4.1/openmpi-4.1.6.tar.gz";
      flake = false;
    };
  };
  outputs = { self, nixpkgs, flake-utils, mpi-src }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pin-mpi = final: prev: {
            mpi = prev.mpi.overrideAttrs (old: {
              version = "4.1.6";
              src = mpi-src;
            });
          };
          pkgs = nixpkgs.legacyPackages.${system}.extend pin-mpi;
        in
        with pkgs;
        {
          devShells.default = mkShell {
            buildInputs = [
              pkgs.R
              pkgs.rPackages.Rmpi
              pkgs.mpi
            ];
          };
        }
      );
}
