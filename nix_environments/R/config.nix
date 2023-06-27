{ pkgs ? import <nixpkgs> {} }:
{
   packageOverrides = pkgs: {      
                                                           
     # R environnement
     rEnv = pkgs.rWrapper.override {                                                                                                                                                                                                         
       packages = with pkgs.rPackages; [ 

           #################################################
           # You can list your R packages below and intall
           # an R environement with:
           #      nix-env -f "<nixpkgs>" -iA rEnv
           #################################################
           devtools
           (buildRPackage {
               name = "rfate";
               src = pkgs.fetchFromGitHub {
                 owner = "leca-dev";
                 repo = "RFate";
                 rev = "0dbe113";
                 sha256 = "0w2gg882rc348ak80gdss92g2wqi6h94fwsq946v6jn84fgwpbgd";
               };
               propagatedBuildInputs = with pkgs ; [ 
                 proj data_table R_utils Rcpp ggplot2 ggthemes raster ggnewscale ggrepel
                 ggExtra gridExtra cowplot reshape2 foreach phyloclim RcppThread doParallel
                 ape huge cluster adehabitatHR adehabitatMA ade4 PresenceAbsence FD BH 
                 pkgs.gdal pkgs.proj pkgs.sqlite pkgs.zlib
               ];
           })
       ];
     };
   };
}
