{
  description = "Flake: Python 3.12.17";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/2941267bd2be3070b98b779910fdf12eb81979e6";
  };

  nixConfig.bash-prompt = "\\e[35m\[nix-develop (\\h)\]\\e[34m\\w\\e[39m$ ";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        allowUnfree = true;
    };
    in
    {
      formatter.${system} = pkgs.nixpkgs-fmt;

      devShells.${system} = rec {
        default = pkgs.mkShell {
          xlibPath = with pkgs.xorg; pkgs.lib.makeLibraryPath [ libX11 libXdmcp libXau libXext libxcb ];
          libPath = with pkgs ; pkgs.lib.makeLibraryPath [ 
                          stdenv.cc.cc
                          openssl zlib 
                        ];
          buildInputs = [
           ( pkgs.python3.withPackages(ps: with ps; [
                numpy
          ]))
         ] ++ [pkgs.lsb-release];
         shellHook= ''
             export LD_LIBRARY_PATH=${default.libPath}:$LD_LIBRARY_PATH
         '';  
        };
      };
    };
}
