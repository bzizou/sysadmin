
#Snippet for cuda-toolkit, thanks to <Marc.Coiffier@univ-grenoble-alpes.fr> 
# as nixpkgs gcc is too recent to work with nvcc (here, we are using
# gcc11 in place of the default gcc12 of stdenv)

let nixpkgs = import <nixpkgs> {};

in nixpkgs.mkShell.override { stdenv = nixpkgs.stdenvNoCC; } {
  buildInputs = with nixpkgs; [
    gcc11
    cmake
    pkg-config
    (nur.repos.gricad.openmpi4.override {
      cudaSupport = true;
      inherit cudatoolkit;
    })
    cudatoolkit
  ];
  NIX_SHELL_PROMPT_TAG = "cudatoolkit";
}
