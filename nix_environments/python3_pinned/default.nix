# Pin the nixpkgs version
let
  hostPkgs = import <nixpkgs> {};
  pinnedPkgs = hostPkgs.fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "23.05";
    sha256 = "sha256-btHN1czJ6rzteeCuE/PNrdssqYD2nIA4w48miQAFloM";
  };
in
let
  pkgs = (import pinnedPkgs) {
  config = rec {
    allowUnfree = true;
    };
  };

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
    numpy
    matplotlib
    h5py
    (buildPythonPackage rec {
      name = "mat73";
      version = "0.62";
      propagatedBuildInputs = with self; [ numpy h5py scipy ];
      src = pkgs.fetchurl{
        url = "mirror://pypi/m/mat73/mat73-${version}.tar.gz";
        sha256 = "sha256-uO6g08ULzX1RwMzVGnNlDDpbjQWZB0+5nefKoxOFXiw=";
      };
    })
  ] ++ [ lsb-release ];
  shellHook = ''
    export LD_LIBRARY_PATH=${libPath}:$LD_LIBRARY_PATH
    alias pip="PIP_PREFIX='$(pwd)/_build/pip_packages' TMPDIR='$HOME' \pip"
    export PYTHONPATH="$(pwd)/_build/pip_packages/lib/python3.8/site-packages:$PYTHONPATH"
    export PATH="$(pwd)/_build/pip_packages/bin:$PATH"
    unset SOURCE_DATE_EPOCH
  '';
}

