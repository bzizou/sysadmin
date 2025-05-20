# A flake for python that can be called either as a dev shell:
#   nix develop
# or that can be ran as a python interpreter:
#   nix run
# It can also be installed into the profile:
#   nix profile install
# or (directly from github!):
#  nix profile install github:bzizou/sysadmin?dir=nix_environments/xdas
#
# Customize your python packages in the lines with the "#### HERE" comment
# Also customize your pinned nixpkgs version in the inputs

{
  description = "Flake: Python with pyslsqp";

  inputs = {
    nixpkgs.url = "github:bzizou/nixpkgs/59acb84d09c7b2cca1453c4ee52a6a2dd5c91664";
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

#### HERE goes the custom python packages definitions ################ 
         mypslsqp= pkgs.python3.pkgs.buildPythonPackage rec {
                   name = "pyslsqp";
                   src = pkgs.fetchFromGitHub {
                     owner = "anugrahjo";
                     repo = "pyslsqp";
                     rev = "v0.1.3";
                     sha256 = "sha256-FuK8uPaIPKKlbhymhHUqt4NdMPAPPykV1rymbgZvXlU";
                   };
                   # Build time dependencies:
                   nativeBuildInputs = [ pkgs.gfortran ] ++ (with pkgs.python3.pkgs; [ meson meson-python ]);
                   # Runtime dependencies:
                   buildInputs = with pkgs.python3.pkgs; [ numpy h5py matplotlib ];
          };

#######################################################################
 
          mypy = pkgs.python3.withPackages(ps: with ps; [

#### HERE goes the Python packages list #### 
                 numpy
                 ipython
                 virtualenv
                 pip
                 notebook
                 pandas
                 scipy
                 matplotlib
                 h5py
                 mypslsqp
###########################################

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
      packages.x86_64-linux.default = shell.mypy;
      formatter.${system} = pkgs.nixpkgs-fmt;
      devShells.${system}.default = shell; 
      apps.${system}.default = {
        type = "app";
        pname = "my-python";
        program = "${runner}/bin/my-python";
      };
    };
}
