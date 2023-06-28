# Pin the nixpkgs version
let
  hostPkgs = import <nixpkgs> {};
  pinnedPkgs = hostPkgs.fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "20.03";
    sha256 = "0182ys095dfx02vl2a20j1hz92dx3mfgz2a6fhn31bqlp1wa8hlq";
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
  name = "hypsimpShell";

  # Put system dependencies here
  libPath = with pkgs ; lib.makeLibraryPath [
                          stdenv.cc.cc 
                          zlib
                          scons
                          boost
                          openexr
                          ilmbase
                          libjpeg
                          libpng
                          xercesc
                          eigen
                          mesa_noglu
                          netcdf
                          netcdfcxx4
                          glew110
                          xorg.libX11
                          xorg.libXxf86vm
                          fftw
                          cfitsio
                          gdal
                        ];

  # Put python modules deps here
  buildInputs = with python2.pkgs; [
    numpy
    scipy
    matplotlib
    gdal
    netcdf4
  ] ++ [ lsb-release ];

  # Customize shell variables here
  shellHook = ''
    export LD_LIBRARY_PATH=${libPath}:$LD_LIBRARY_PATH
    alias pip="PIP_PREFIX='$(pwd)/_build/pip_packages' TMPDIR='$HOME' \pip"
    export PYTHONPATH="/home/doutes/Hypsim/mitsuba/dist/python/2.7:$(pwd)/_build/pip_packages/lib/python2.7/site-packages:$PYTHONPATH"
    export PATH="/home/doutes/Hypsim/mitsuba/dist:$(pwd)/_build/pip_packages/bin:$PATH"
    unset SOURCE_DATE_EPOCH
    export OEXRINCLUDE="${openexr.dev}/include/OpenEXR"
    export ILMBASEINCLUDE="${ilmbase.dev}/include/OpenEXR"
    export EIGENINCLUDE="${eigen}/include/eigen3"
    export CFITSIODIR="${cfitsio}"
    export MITSUBA_DIR=/home/doutes/Hypsim/mitsuba
    export HYPSIM_BIN=/home/doutes/Hypsim/mitsuba/dist
    export HYPSIM_PYTHON=/home/doutes/Hypsim/python
    export HYPSIM_SH=/home/doutes/Hypsim
    export HDF5_DISABLE_VERSION_CHECK=1
  '';
}

