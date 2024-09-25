{
  description = "Rmpi flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.05";
    #nixpkgs-old.url = "github:nixos/nixpkgs?ref=nixos-23.11";
    nixpkgs-old = {
      url = "github:nixos/nixpkgs?ref=nixos-18.09";
      flake = false;
    };
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, nixpkgs-old, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          #oldpkgs = nixpkgs-old.legacyPackages.${system}; # For nixos >= 20.05 with flake = true
          oldpkgs = import nixpkgs-old {  inherit system; }; # For older nixpkgs
          pkgs = nixpkgs.legacyPackages.${system}.extend rPackages.Rmpi-pin ;
          rPackages.Rmpi-pin = final: prev: {
            rPackages.Rmpi = prev.rPackages.Rmpi.overrideAttrs (old: {
              nativeBuildInputs = [ oldpkgs.openmpi pkgs.R ];
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
