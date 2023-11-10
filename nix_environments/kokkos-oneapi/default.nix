# Shell environment with intel-oneapi from the NUR respository of GRICAD
# PLace this file in a directory and simply do "nix-shell" from it

let                                                               
  hostPkgs = import <nixpkgs> {};                                 
  pinnedPkgs = hostPkgs.fetchFromGitHub {                         
    owner = "NixOS";                                              
    repo = "nixpkgs";                                             
    rev = "21.05";                                                
    sha256 = "sha256:1ckzhh24mgz6jd1xhfgx0i9mijk6xjqxwsshnvq789xsavrmsc36";
  };                                                              
in                                                                
let                                                               
  pkgs = (import pinnedPkgs) {                                    
  config = rec {                                                  
    allowUnfree = true;                                           
    permittedInsecurePackages = [
        "qtwebkit-5.212.0-alpha4"  
      ];                           
    };                                                            
  };                                                              
in with pkgs;
let 
  nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/f1b210733ae9e85c15f84028c6539cdace20ebe0.tar.gz") { inherit pkgs; };
in mkShell rec {
  name = "kokkos-env";
  buildInputs = [ gcc glibc cmake nur.repos.gricad.intel-oneapi nur.repos.gricad.openmpi];
  shellHook = ''
    source ${nur.repos.gricad.intel-oneapi}/setvars.sh
    export GCCROOT=${gcc}
    export GXXROOT=${gcc}
    export CC=icc
    export CXX=icpc
    export GXX_INCLUDE=${glibc.dev}/include
    export CXXFLAGS="-isystem ${stdenv.cc.cc}/include/c++/${stdenv.cc.version} -isystem ${stdenv.cc.cc}/include/c++/${stdenv.cc.version}/x86_64-unknown-linux-gnu $NIX_CFLAGS_COMPILE"
    export CFLAGS="-isystem ${stdenv.cc.cc}/include/c++/${stdenv.cc.version} -isystem ${stdenv.cc.cc}/include/c++/${stdenv.cc.version}/x86_64-unknown-linux-gnu $NIX_CFLAGS_COMPILE"
  '';
}
