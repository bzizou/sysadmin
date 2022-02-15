with import <nixpkgs> {};
mkShell {
  name = "tensorflow-cuda-shell";
  buildInputs = with python3.pkgs; [ 
    pip
    numpy
    setuptools
  ] ++ [ lsb-release ];
  shellHook = ''
    export LD_LIBRARY_PATH=${pkgs.openssl.out}/lib:${pkgs.stdenv.cc.cc.lib}/lib:${pkgs.cudatoolkit_11}/lib:${pkgs.cudnn_cudatoolkit_11}/lib:${pkgs.cudatoolkit_11.lib}/lib:/usr/lib/x86_64-linux-gnu:${pkgs.expat}/lib:${pkgs.zlib}/lib:$LD_LIBRARY_PATH:
    alias pip="PIP_PREFIX='$(pwd)/_build/pip_packages' TMPDIR='$HOME' \pip"
    export PYTHONPATH="$(pwd)/_build/pip_packages/lib/python3.9/site-packages:$PYTHONPATH"
    export PATH="$(pwd)/_build/pip_packages/bin:$PATH"
    unset SOURCE_DATE_EPOCH
  '';
}
