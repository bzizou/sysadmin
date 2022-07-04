with import <nixpkgs> {
  config = {
    allowUnfree = true;
    cudaSupport = true;
  };
};

mkShell rec {
  name = "tensorflow-cuda-shell";
  xlibPath = with pkgs.xlibs ; lib.makeLibraryPath [ libX11 libXdmcp libXau libXext libxcb ]; 
  libPath = with pkgs ; lib.makeLibraryPath [ 
                          stdenv.cc.cc cudatoolkit_11 cudnn_cudatoolkit_11 
                          libtiff openssl zlib libbsd expat glib libjpeg libpng
                          libffi libvorbis gnutls libdrm gmp numactl elfutils
	                  libelf libogg p11-kit libtasn1 nettle
                        ]; 
  buildInputs = with python3.pkgs; [ 
    pip
    numpy
    setuptools
    opencv4
    pytorch
    torchvision
  ] ++ [ lsb-release ];
  shellHook = ''
    export LD_LIBRARY_PATH=${libPath}:${xlibPath}:${pkgs.cudatoolkit_11}/lib:/usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH
    alias pip="PIP_PREFIX='$(pwd)/_build/pip_packages' TMPDIR='$HOME' \pip"
    export PYTHONPATH="$(pwd)/_build/pip_packages/lib/python3.9/site-packages:$PYTHONPATH:/bettik/PROJECTS/pr-orchampvision/COMMON/pytorch-nixenv/megadetector/ai4eutils:/bettik/PROJECTS/pr-orchampvision/COMMON/pytorch-nixenv/megadetector/CameraTraps:/bettik/PROJECTS/pr-orchampvision/COMMON/pytorch-nixenv/deepfauneapi/software:/bettik/PROJECTS/pr-orchampvision/COMMON/pytorch-nixenv/megadetector/yolov5"
    export PATH="$(pwd)/_build/pip_packages/bin:$PATH"
    unset SOURCE_DATE_EPOCH
  '';
}

