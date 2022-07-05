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
	                  libelf libogg p11-kit libtasn1 nettle e2fsprogs libgcrypt
                          keyutils
                        ];
  
  buildInputs = with python3.pkgs; [ 
    pip
    numpy
    setuptools
    opencv4
    pytorch
    torchvision
    (buildPythonPackage {                                                                      
      name = "absl-py";                                                                  
      src = pkgs.fetchFromGitHub {                                                      
        owner = "abseil";                                                            
        repo = "abseil-py";                                                                
        rev = "v1.1.0";
        sha256 = "058ccbcgx6jw9fnrrv99a1y8f13pkxn4656mjkx7pc78knyc13p5";
      };
      doCheck = false;                
      propagatedBuildInputs = with pkgs ; [ six ];
    })
    tensorflow
  ] ++ [ lsb-release ];
  shellHook = ''
    export LD_LIBRARY_PATH=${libPath}:${xlibPath}:${pkgs.cudatoolkit_11}/lib:/usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH
    alias pip="PIP_PREFIX='$(pwd)/_build/pip_packages' TMPDIR='$HOME' \pip"
    export PYTHONPATH="$(pwd)/_build/pip_packages/lib/python3.9/site-packages:$PYTHONPATH:/bettik/PROJECTS/pr-orchampvision/COMMON/pytorch-nixenv/megadetector/ai4eutils:/bettik/PROJECTS/pr-orchampvision/COMMON/pytorch-nixenv/megadetector/CameraTraps:/bettik/PROJECTS/pr-orchampvision/COMMON/pytorch-nixenv/deepfauneapi/software:/bettik/PROJECTS/pr-orchampvision/COMMON/pytorch-nixenv/megadetector/yolov5"
    export PATH="$(pwd)/_build/pip_packages/bin:$PATH"
    unset SOURCE_DATE_EPOCH
  '';
}

