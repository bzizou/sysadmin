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

# Override some python packages globaly
let
  pkgs = (import pinnedPkgs) {
  config = rec {
    allowUnfree = true;
    cudaSupport = true;
    packageOverrides = pkgs: rec {
      python3 = pkgs.python3.override rec {
        packageOverrides = self: super: rec {

          # Apply a patch to pytorch
          pytorch = pkgs.python3.pkgs.pytorch.overrideAttrs (attrs: {
            patches = (attrs.patches or []) ++ [
              ./pytorch.patch
            ];
          });

          # CLICK == 8.0.4 (needed as is for SAHI)
          #click = pkgs.python3.pkgs.buildPythonPackage rec {
          #  pname = "click";
          #  version = "8.0.4";
          #  src = pkgs.python3.pkgs.fetchPypi {
          #    inherit pname version;
          #    sha256 = "1nqa17zdd16fhiizziznx95ygkcxz4f3h8qfr4lb2pvw52qxfn44";
          #  };
          #  doCheck = false;                
          #};

          # PIP
          #pip = pkgs.python3.pkgs.buildPythonPackage rec {
          #  pname = "pip"; 
          #  version = "22.3";                                                               
          #  src = pkgs.fetchFromGitHub {                                                      
          #    owner = "pypa";                                                            
          #    repo = "pip";                                                                
          #    rev = version;
          #    sha256 = "179k3z09y55rgs2cpwm0bymdl695dagfs20ksf8xksq54xmnky70";
          #  };
          #  doCheck = false;
          #  pipInstallFlags = [ "--ignore-installed" ];
          #  meta.license = [ "gpl" ];
          #};
        };
      };
    };
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

    # UPGRADED ABSL-PY
    my_absl-py = python3.pkgs.buildPythonPackage rec {
      name = "absl-py";                                                                  
      src = pkgs.fetchFromGitHub {                                                      
        owner = "abseil";                                                            
        repo = "abseil-py";                                                                
        rev = "v1.1.0";
        sha256 = "058ccbcgx6jw9fnrrv99a1y8f13pkxn4656mjkx7pc78knyc13p5";
      };
      doCheck = false;                
      propagatedBuildInputs = with python3.pkgs ; [ six ];
    };

    # TQDM
    my_tqdm = python3.pkgs.buildPythonPackage rec {
      pname = "tqdm";
      version = "4.64.1";
      src = python3.pkgs.fetchPypi {
       inherit pname version;
       sha256 = "1r7i9kswpnrx4ppfvzz6discb04j1rqkqxdwa2sc2la900m6hksz";
      };
      doCheck = false;                
    };

    # THOP
    my_thop = python3.pkgs.buildPythonPackage rec {
      pname = "thop";
      version = "0.1.1";
      src = pkgs.fetchFromGitHub {                                                      
        owner = "Lyken17";                                                            
        repo = "pytorch-OpCounter";
        rev = "43c064a";                                                              
        sha256 = "0fw3xd6w19sd4dm3d4axgfxmlf3xjnymj5zi4626zw6gawad7f3s";
      };
      doCheck = false;                
      propagatedBuildInputs = with python3.pkgs ; [ pytorch  ];
    };

    # PYBBOXES
    my_pybboxes = python3.pkgs.buildPythonPackage rec {
      pname = "pybboxes";
      version = "0.1.5";
      src = python3.pkgs.fetchPypi {
       inherit pname version;
       sha256 = "1wkak6aw531sviqpmi28343sjg5aaggii09cz12kkdcrpzlm8ra6";
      };
      doCheck = false;                
      propagatedBuildInputs = with python3.pkgs ; [ numpy ];
    };

    # SAHI
    my_sahi = python3.pkgs.buildPythonPackage rec {
      pname = "sahi";
      version = "0.10.7";
      src = python3.pkgs.fetchPypi {
       inherit pname version;
       sha256 = "0nal2x7qakkc2a3jz8mpzlmd45wfs5q6dmqyvy1fh1rchvs53kvi";
      };
      doCheck = false;                
      postPatch = ''
        substituteInPlace requirements.txt \
          --replace "opencv-python" "opencv"
        substituteInPlace requirements.txt \
          --replace "click==8.0.4" ""
      '';
      propagatedBuildInputs = with python3.pkgs ; [ shapely fire pyyaml requests opencv4 pillow terminaltables my_tqdm my_pybboxes click];
    };

    # YOLOV5
    my_yolov5 = python3.pkgs.buildPythonPackage rec {
      name = "yolov5";                                                                  
      src = pkgs.fetchFromGitHub {                                                      
        owner = "fcakyon";                                                            
        repo = "yolov5-pip";                                                                
        rev = "6.2.2";
        sha256 = "0zq7578cm8dbi428q6hkavhqpha4y9jbh0717fjf4l8mp23l6qb0";
      };
      doCheck = false;                
      postPatch = ''
        substituteInPlace requirements.txt \
          --replace "opencv-python" "opencv"
      '';
      propagatedBuildInputs = with python3.pkgs ; [ scipy tensorboard matplotlib pytorch fire psutil pandas torchvision boto3 seaborn ipython my_tqdm my_thop click my_sahi ];
    };

    # TIMM
    my_timm = python3.pkgs.buildPythonPackage rec {
      pname = "timm";
      version = "0.6.11";
      src = python3.pkgs.fetchPypi {
       inherit pname version;
       sha256 = "199zgg574gijw52jn4fhfzaqlbwhq0z8kav4k34xifssnr18hmh9";
      };
      doCheck = false;                
      propagatedBuildInputs = with python3.pkgs ; [ pyyaml torchvision huggingface-hub packaging ];
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

# Create the shell
in mkShell rec {
  name = "pytorch-cuda-shell";
  xlibPath = with pkgs.xorg ; lib.makeLibraryPath [ libX11 libXdmcp libXau libXext libxcb ]; 
  libPath = with pkgs ; lib.makeLibraryPath [ 
                          stdenv.cc.cc cudaPackages_11.cudatoolkit
                          libtiff openssl zlib libbsd expat glib libjpeg libpng
                          libffi libvorbis gnutls libdrm gmp numactl elfutils
	                  libelf libogg p11-kit libtasn1 nettle e2fsprogs libgcrypt
                          keyutils bzip2 libgpg-error xz
                        ];
  buildInputs = with python3.pkgs; [ 
    my_pip
    my_timm
    my_absl-py
    my_yolov5
    my_tqdm
    my_sahi
    click
    my_python-irodsclient
    numpy
    setuptools
    opencv4
    pytorch
    pandas
    torchvision
    matplotlib
    seaborn
    pandas 
    pillow
    humanfriendly
    jsonpickle
    statistics
    requests
    #python-irodsclient
    #timm
    #tensorflowWithCuda
  ] ++ [ lsb-release ];
  shellHook = ''
    export LD_LIBRARY_PATH=${libPath}:${xlibPath}:${pkgs.cudaPackages_11.cudatoolkit}/lib:/usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH
    alias pip="PIP_PREFIX='$(pwd)/_build/pip_packages' TMPDIR='$HOME' \pip"
    export PYTHONPATH="${my_absl-py}/lib/python3.9/site-packages:${my_pip}/lib/python3.9/site-packages:$(pwd)/_build/pip_packages/lib/python3.9/site-packages:$PYTHONPATH:/bettik/PROJECTS/pr-orchampvision/COMMON/orchampvision-nixenv/megadetector/ai4eutils:/bettik/PROJECTS/pr-orchampvision/COMMON/orchampvision-nixenv/megadetector/CameraTraps:/bettik/PROJECTS/pr-orchampvision/COMMON/orchampvision-nixenv/deepfauneapi/software:/bettik/PROJECTS/pr-orchampvision/COMMON/orchampvision-nixenv/megadetector/yolov5"
    export PATH="$(pwd)/_build/pip_packages/bin:$PATH"
    unset SOURCE_DATE_EPOCH
  '';
}

