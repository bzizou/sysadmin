{
  description = "Rmpi fix flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
    rmpi-src = {
      url = "https://cran.r-project.org/src/contrib/Archive/Rmpi/Rmpi_0.7-2.tar.gz";
      flake = false;
    };
  };
  outputs = { self, nixpkgs, flake-utils, rmpi-src }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = nixpkgs.legacyPackages.${system}.extend rPackages.Rmpi-pin ;
          rPackages.Rmpi-pin = final: prev: {
            rPackages.Rmpi = prev.rPackages.Rmpi.overrideAttrs (old: {
              src = rmpi-src;
              version = "0.7-2";
              name = "Rmpi-0.7-2";
              env = (old.env or { }) // {
                NIX_CFLAGS_COMPILE = old.env.NIX_CFLAGS_COMPILE + " -DMPI2";  # <- This is the fix!
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
              pkgs.openmpi
            ];
          };
        }
      );
}
