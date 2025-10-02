# A flake for openmpi with cuda that can be called either as a dev shell:
#   nix develop
# It can also be installed into the profile:
#   nix profile install
# or (directly from github!):
#  nix profile install github:bzizou/sysadmin?dir=nix_environments/openmpi-cuda
#
{
  description = "Flake: openmpi with cuda";

  inputs = {
    nixpkgs.url = "github:bzizou/nixpkgs/a33463999d9599a0c339f9df7a7ff31c39d1b799";
  };

  nixConfig.bash-prompt = "\\e[35m\[nix-develop (\\h)\]\\e[34m\\w\\e[39m$ ";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        config.cudaSupport = true;
      };
      shell = pkgs.mkShell rec {
        packages = with pkgs; [
                          stdenv.cc.cc 
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
