{
  description = "Rmpi flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.05";
    nixpkgs-old.url = "github:nixos/nixpkgs?ref=nixos-20.09";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, nixpkgs-old, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          oldpkgs = nixpkgs-old.legacyPackages.${system};
          pkgs = nixpkgs.legacyPackages.${system}.extend rPackages.Rmpi-pin ;
          rPackages.Rmpi-pin = final: prev: {
            rPackages.Rmpi = prev.rPackages.Rmpi.overrideAttrs (old: {
              buildInputs = [ oldpkgs.openmpi pkgs.R ];
            });
          };
        in
        with pkgs;
        {
          devShells.default = mkShell {
            buildInputs = [
              pkgs.R
              pkgs.rPackages.Rmpi
              oldpkgs.openmpi
            ];
          };
        }
      );
}
