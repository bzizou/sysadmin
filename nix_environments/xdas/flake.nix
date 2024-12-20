# A flake for python that can be called either as a dev shell:
#   nix develop
# or that can be ran as a python interpreter:
#   nix run
# Customize your python packages in the lines with the "#### HERE" comment
# Also customize your pinned nixpkgs version in the inputs

{
  description = "Flake: Python 3.12.17";

  inputs = {
    nixpkgs.url = "github:bzizou/nixpkgs/a33463999d9599a0c339f9df7a7ff31c39d1b799";
  };

  nixConfig.bash-prompt = "\\e[35m\[nix-develop (\\h)\]\\e[34m\\w\\e[39m$ ";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        allowUnfree = true;
      };
      shell = pkgs.mkShell rec {
          libPath = with pkgs ; pkgs.lib.makeLibraryPath [ 
                          stdenv.cc.cc
                          openssl zlib 
                        ];
          mypy = pkgs.python3.withPackages(ps: with ps; [

#### HERE goes the Python packages list #### 
                 numpy
                 xdas
                 torch
############################################

          ]);
          buildInputs = [ ( mypy ) ] ++ [pkgs.lsb-release];
          shellHook= ''
             export LD_LIBRARY_PATH=${shell.libPath}:$LD_LIBRARY_PATH
          '';  
      };
      runner = pkgs.writeShellApplication {
        name = "my-python";
        runtimeInputs = shell.buildInputs;
        text = ''
          ${shell.mypy.interpreter}
        '';
      };
    in
    {
      formatter.${system} = pkgs.nixpkgs-fmt;
      devShells.${system}.default = shell; 
      apps.${system}.default = {
        type = "app";
        program = "${runner}/bin/my-python";
      };
    };
}
