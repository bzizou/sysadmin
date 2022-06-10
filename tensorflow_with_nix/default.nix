with import <nixpkgs> {};
mkShell rec {
  name = "tensorflow-cuda-shell";
  # libPath and xlibPath provided here with probably more things than you need
  # if you remove the example opencv4 buildInput given here as an example of supplementary
  # dependency. Feel free to cistomize.
  xlibPath = with pkgs.xlibs ; lib.makeLibraryPath [ libX11 libXdmcp libXau libXext libxcb ]; 
  libPath = with pkgs ; lib.makeLibraryPath [ 
                          stdenv.cc.cc cudatoolkit_11 cudnn_cudatoolkit_11 
                          libtiff openssl zlib libbsd expat glib libjpeg libpng
                          libffi libvorbis gnutls libdrm gmp numactl elfutils
	                  libelf libogg p11-kit libtasn1 nettle
                        ]; 
  # Example including opencv4 as a 
  buildInputs = with python3.pkgs; [ 
    pip
    numpy
    setuptools
    opencv4 
  ] ++ [ lsb-release ];
  shellHook = ''
    export LD_LIBRARY_PATH=${libPath}:${xlibPath}:/usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH
    alias pip="PIP_PREFIX='$(pwd)/_build/pip_packages' TMPDIR='$HOME' \pip"
    export PYTHONPATH="$(pwd)/_build/pip_packages/lib/python3.9/site-packages:$PYTHONPATH"
    export PATH="$(pwd)/_build/pip_packages/bin:$PATH"
    unset SOURCE_DATE_EPOCH
  '';
}

