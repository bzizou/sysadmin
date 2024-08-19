#! /usr/bin/env nix-shell
#!nix-shell -i bash -p boost -p gcc -p gnumake -p eigen
#!nix-shell -I nixpkgs=channel:nixos-22.05

export BOOST_INC=`echo $NIX_CFLAGS_COMPILE| grep -o -P '/nix/store[^ ]+boost[^ ]+'|head -1`
export BOOST_LIB=`echo $NIX_LDFLAGS |grep -o -P '/nix/store[^ ]+boost[^ ]+/lib'|head -1`
export EIGEN_INC=`echo $NIX_CFLAGS_COMPILE| grep -o -P '/nix/store[^ ]+eigen[^ ]+'|head -1`

make EIGEN_INC="$EIGEN_INC/eigen3" BOOST_LIB=$BOOST_LIB BOOST_INC=$BOOST_INC linux
