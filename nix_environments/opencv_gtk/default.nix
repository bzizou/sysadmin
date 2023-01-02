# Pin the nixpkgs version
let
  hostPkgs = import <nixpkgs> {};
  pinnedPkgs = hostPkgs.fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "22.05";
    sha256 = "1ckzhh24mgz6jd1xhfgx0i9mijk6xjqxwsshnvq789xsavrmsc36";
  };
in
let
  pkgs = (import pinnedPkgs) {
  config = rec {
    allowUnfree = true;
    };
  };
  opencvGtk = pkgs.python3.pkgs.opencv4.override (old : { enableGtk2 = true; });

# Create the shell
in with pkgs;
let
in mkShell rec {
  name = "python3shell";
  libPath = with pkgs ; lib.makeLibraryPath [
                          stdenv.cc.cc 
                          zlib
                        ];
  buildInputs = with python3.pkgs; [
    pip
    setuptools
    scipy
    matplotlib
    h5py
    opencvGtk
  ] ++ [ lsb-release ];
  shellHook = ''
    export LD_LIBRARY_PATH=${libPath}:$LD_LIBRARY_PATH
    alias pip="PIP_PREFIX='$(pwd)/_build/pip_packages' TMPDIR='$HOME' \pip"
    export PYTHONPATH="$(pwd)/_build/pip_packages/lib/python3.8/site-packages:$PYTHONPATH"
    export PATH="$(pwd)/_build/pip_packages/bin:$PATH"
    unset SOURCE_DATE_EPOCH
  '';
}

