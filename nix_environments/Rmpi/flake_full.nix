{
  description = "Rmpi flake complete example with legacy openmpi";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-23.05";
    nixpkgs-old.url = "github:nixos/nixpkgs?ref=nixos-21.05";
    #nixpkgs-old = {
    #  url = "github:nixos/nixpkgs?ref=nixos-18.09";
    #  flake = false;
    #};
    flake-utils.url = "github:numtide/flake-utils";
    rmpi-src = {
      url = "https://cran.r-project.org/src/contrib/Archive/Rmpi/Rmpi_0.7-2.tar.gz";
      flake = false;
    };
  };
  outputs = { self, nixpkgs, nixpkgs-old, flake-utils, rmpi-src }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          oldpkgs = nixpkgs-old.legacyPackages.${system}; # For nixos >= 20.05 with flake = true
          #oldpkgs = import nixpkgs-old {  inherit system; }; # For older nixpkgs
          pkgs = nixpkgs.legacyPackages.${system}.extend rPackages.Rmpi-pin ;
          rPackages.Rmpi-pin = final: prev: {
            rPackages.Rmpi = prev.rPackages.Rmpi.overrideAttrs (old: {
              src = rmpi-src;
              version = "0.7-2";
              name = "Rmpi-0.7-2";
              nativeBuildInputs = [ oldpkgs.openmpi pkgs.R ];
              configureFlags = [
                "--with-Rmpi-type=OPENMPI"
              ];
              env = (old.env or { }) // {
                NIX_CFLAGS_COMPILE = old.env.NIX_CFLAGS_COMPILE + " -DMPI2";
              };
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
