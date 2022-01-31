Using tensorflow and Keras with NIX
===================================

This method is ok for the GRICAD "bigfoot" platform. It might run elsewhere...

Installation
------------

```
mkdir tensorflow
cd tensorflow
wget https://raw.githubusercontent.com/bzizou/sysadmin/master/tensorflow_with_nix/default.nix
nix-shell -I "nixpkgs=channel:nixos-21.11"
# (You can change nixpkgs version if needed above)
# (You can also change Cuda version into the default.nix file)
[nix-shell:~/tensorflow]$  pip install tensorflow-gpu tensorflow-datasets
```

You can specify a different version for Tensorflow:

```
[nix-shell:~/tensorflow]$ pip install tensorflow==2.3 tensorflow-datasets
```

GPU access test

```
[nix-shell:~/tensorflow]$ python
Python 3.9.6 (default, Jun 28 2021, 08:57:49) 
[GCC 10.3.0] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> import tensorflow as tf
>>> print(tf.test.gpu_device_name())
2022-01-31 17:14:48.249019: I tensorflow/core/platform/cpu_feature_guard.cc:151] This TensorFlow binary is optimized with oneAPI Deep Neural Network Library (oneDNN) to use the following CPU instructions in performance-critical operations:  AVX2 FMA
To enable them in other operations, rebuild TensorFlow with the appropriate compiler flags.
2022-01-31 17:14:49.434001: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1525] Created device /device:GPU:0 with 38416 MB memory:  -> device: 0, name: NVIDIA A100-PCIE-40GB, pci bus id: 0000:21:00.0, compute capability: 8.0
/device:GPU:0
>>> 
```

Keras is integrated into Tensorflow v2:

```
>>> from tensorflow import keras
```

Runtime
-------

Example:

```
cd ~/tensorflow
wget https://raw.githubusercontent.com/bzizou/sysadmin/master/tensorflow_with_nix/test_gpu.py
export NIX_PATH="nixpkgs=channel:nixos-21.11"
nix-shell --command 'python test_gpu.py'
```


