# A flake for python that can be called either as a dev shell:
#   nix develop
# or that can be ran as a python interpreter:
#   nix run
# It can also be installed into the profile:
#   nix profile install
# or (directly from github!):
#  nix profile install github:bzizou/sysadmin?dir=nix_environments/R
#
# Customize your R packages in the lines with the "#### HERE" comment
# Also customize your pinned nixpkgs version in the inputs

{
  description = "Flake: R with Julia";

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
          myR = pkgs.rWrapper.override{ packages = with pkgs.rPackages; [

#### HERE goes the R packages list #### 
                 devtools
                 JuliaCall
                 knitr
                 remotes
                 raster
                 ggplot2
                 plyr
                 dplyr
                 magrittr
                 lme4
                 spatstat_explore
                 spatstat_geom
                 spdep
                 Matrix
                 MuMIn
                 doParallel
                 RcppArmadillo
                 rjson
                 foreach
                 rmarkdown
                 ggExtra
                 igraph
                 terra
                 sp
                 akima
                 gdistance
                 GA
                 XRJulia
                 # ResistanceGA from sources:
                 (buildRPackage {
                   name = "ResistanceGA";
                   src = pkgs.fetchFromGitHub {
                     owner = "wpeterman";
                     repo = "ResistanceGA";
                     rev = "9442376";
                     sha256 = "sha256-qicOnyBTZmcxnSulSEZ0oKHMMM1zRud1FZEgYSbNK4I=";
                   };
                   propagatedBuildInputs = with pkgs ; [
                     devtools raster ggplot2 ggExtra akima plyr dplyr gdistance GA 
                     lme4 Matrix MuMIn spatstat spdep doParallel JuliaCall XRJulia
                   ];
                 })
    
############################################

          ]; };
          buildInputs = [ ( myR ) ] ++ [pkgs.lsb-release];
          shellHook= ''
             export LD_LIBRARY_PATH=${shell.libPath}:$LD_LIBRARY_PATH
          '';  
      };
      runner = pkgs.writeShellApplication {
        name = "my-R";
        runtimeInputs = shell.buildInputs;
        text = ''
          ${shell.myR}/bin/R
        '';
      };
    in
    {
      packages.x86_64-linux.default = shell.myR;
      formatter.${system} = pkgs.nixpkgs-fmt;
      devShells.${system}.default = shell; 
      apps.${system}.default = {
        type = "app";
        pname = "my-R";
        program = "${runner}/bin/my-R";
      };
    };
}
