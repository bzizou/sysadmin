# A flake for openmpi with cuda that can be called either as a dev shell:
#   nix develop
# Runtime example:
#   nix develop flakes_path/openmpi-cuda --command mpirun ...
#
{
  description = "Flake: openmpi with cuda";

  inputs = {
    nixpkgs.url = "github:bzizou/nixpkgs/04b167bc34e45806968a3972c928c2006ccefcc6";
  };

  nixConfig.bash-prompt = "\\e[35m\[nix-develop (\\h)\]\\e[34m\\w\\e[39m$ ";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        config.cudaSupport = true;
        config.enableCuda = true;
      };
      shell = pkgs.mkShell rec {
        packages = with pkgs; [
                          stdenv.cc.cc
                          ucx 
                          openmpi zlib 
                          openssl cudatoolkit
                        ];
    };
    in
    {
      formatter.${system} = pkgs.nixpkgs-fmt;
      devShells.${system}.default = shell; 
    };
}
