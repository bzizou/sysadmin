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
  description = "Flake: pre-commit install for OAR3 dev";

  inputs = {
    nixpkgs.url = "github:bzizou/nixpkgs/9a333eaa80901efe01df07eade2c16d183761fa3";
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
          mypip = pkgs.python3.pkgs.buildPythonPackage rec {
                   name = "pip";
                   src = pkgs.fetchFromGitHub {
                     owner = "pypa";
                     repo = "pip";
                     rev = "22.3";
                     sha256 = "sha256-4PhpaycF69mR0xMI7Z5qJRnaql+g8suEfrkUn8AfM50=";
                   };
                   doCheck = false;
                   pipInstallFlags = [ "--ignore-installed" ];
          };

         myprecommit= pkgs.python3.pkgs.buildPythonPackage rec {
                   name = "precommit";
                   src = pkgs.fetchFromGitHub {
                     owner = "pre-commit";
                     repo = "pre-commit";
                     rev = "v4.2.0";
                     sha256 = "sha256-rUhI9NaxyRfLu/mfLwd5B0ybSnlAQV2Urx6+fef0sGM=";
                   };
          };

#######################################################################
 
          mypy = pkgs.python3.withPackages(ps: with ps; [

#### HERE goes the Python packages list #### 
                 cfgv
                 identify
                 pyyaml
                 nodeenv
                 virtualenv
                 mypip
                 myprecommit
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
