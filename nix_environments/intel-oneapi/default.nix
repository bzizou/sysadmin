# Shell environment with intel-oneapi from the NUR respository of GRICAD
# PLace this file in a directory and simply do "nix-shell" from it

with import <nixpkgs> {
  packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
  };
};

mkShell rec {
  name = "kokkos-env";
  buildInputs = [ gcc glibc cmake nur.repos.gricad.intel-oneapi ];
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
