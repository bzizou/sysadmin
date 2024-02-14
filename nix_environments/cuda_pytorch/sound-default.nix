# Pin the nixpkgs version
let
  hostPkgs = import <nixpkgs> {};
  pinnedPkgs = hostPkgs.fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "22.05";
    sha256 = "0d643wp3l77hv2pmg2fi7vyxn4rwy0iyr8djcw1h5x72315ck9ik";
  };
in
let
  pkgs = (import pinnedPkgs) {
  config = rec {
    allowUnfree = true;
    cudaSupport = true;
    };
  };

in with pkgs;
# Python packages built locally
let
    # UPGRADED PIP
    my_pip = python3.pkgs.buildPythonPackage rec {
      name = "pip";
      src = pkgs.fetchFromGitHub {
        owner = "pypa";
        repo = "pip";
        rev = "22.3";
        sha256 = "179k3z09y55rgs2cpwm0bymdl695dagfs20ksf8xksq54xmnky70";
      };
      doCheck = false;
      pipInstallFlags = [ "--ignore-installed" ];
    };

    # PYTHON-IRODSCLIENT
     my_python-irodsclient = python3.pkgs.buildPythonPackage rec {
      pname = "python-irodsclient";
      version = "1.1.5";
      src = python3.pkgs.fetchPypi {
       inherit pname version;
       sha256 = "10n1ds6wdcx56smhwy2mf4flgkaqpq2grlzbb0g3s68h8vf4p2vv";
      };
      doCheck = false;                
      propagatedBuildInputs = with python3.pkgs ; [ defusedxml prettytable six ];
    };

     # SCIKIT-MAAD
     my_scikit-maad = python3.pkgs.buildPythonPackage rec {
      pname = "scikit-maad";
      version = "1.3.12";
      src = python3.pkgs.fetchPypi {
       inherit pname version;
       sha256 = "09417rhj7snm8yapbh9z4i53gic1xpgc2w3pkkn2716fs9xw3z4s";
      };
      doCheck = false;                
      propagatedBuildInputs = with python3.pkgs ; [ resampy matplotlib numpy scipy scikitimage pandas ];
    };

     # TFLITE-RUNTIME
     #my_tflite-runtime = python3.pkgs.buildPythonPackage rec {
     # pname = "tflite_runtime";
     # version = "2.11.0";
     # src = python3.pkgs.fetchPypi {
     #  inherit pname version;
     #  sha256 = "19417rhj7snm8yapbh9z4i53gic1xpgc2w3pkkn2716fs9xw3z4s";
     # };
     # doCheck = false;                
     # propagatedBuildInputs = with python3.pkgs ; [ tensorflow ];
     #};

# Create the shell
in mkShell rec {
  name = "pytorch-cuda-shell";
  xlibPath = with pkgs.xorg ; lib.makeLibraryPath [ libX11 libXdmcp libXau libXext libxcb ]; 
  libPath = with pkgs ; lib.makeLibraryPath [ 
                          stdenv.cc.cc cudaPackages_11.cudatoolkit
                          libtiff openssl zlib libbsd expat glib libjpeg libpng
                          libffi libvorbis gnutls libdrm gmp numactl elfutils
	                  libelf libogg p11-kit libtasn1 nettle e2fsprogs libgcrypt
                          keyutils bzip2 libgpg-error xz libllvm
                        ];
  buildInputs = with python3.pkgs; [ 
    my_pip
    my_python-irodsclient
    my_scikit-maad
    tensorflow
    ffmpeg
    numpy
    setuptools
    opencv4
    pandas
    pandas 
    requests
  ] ++ [ lsb-release ];
  shellHook = ''
    export LD_LIBRARY_PATH=${libPath}:${xlibPath}:${pkgs.cudaPackages_11.cudatoolkit}/lib:/usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH
    alias pip="PIP_PREFIX='$(pwd)/_build/pip_packages' TMPDIR='$HOME' \pip"
    export PYTHONPATH="${my_pip}/lib/python3.9/site-packages:$(pwd)/_build/pip_packages/lib/python3.9/site-packages:$PYTHONPATH"
    export PATH="$(pwd)/_build/pip_packages/bin:$PATH"
    unset SOURCE_DATE_EPOCH
  '';
}

