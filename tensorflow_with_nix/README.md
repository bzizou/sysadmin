Using tensorflow and Keras with NIX
===================================

This method is ok for the GRICAD "bigfoot" platform. It might run elsewhere...

Installation
------------

```
mkdir tensorflow
cd tensorflow
wget https://raw.githubusercontent.com/bzizou/sysadmin/master/tensorflow_with_nix/default.nix
nix-shell -I "nixpkgs=https://github.com/NixOS/nixpkgs/archive/nixos-21.05.tar.gz"
# (You can change nixpkgs version if needed above)
# (You can also change Cuda version into the default.nix file)
pip install tensorflow tensorflow-datasets
```

You can specify a different version for Tensorflow:

```
pip install tensorflow==2.3 tensorflow-datasets
```

Hello world test:

```
[nix-shell:~/tensorflow]$ python
Python 3.8.9 (default, Apr  2 2021, 11:20:07)
[GCC 10.3.0] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> import tensorflow as tf
2021-06-23 14:55:42.123439: E tensorflow/core/lib/monitoring/collection_registry.cc:77] Cannot register 2 metrics with the same name: /tensorflow/core/saved_model/write/count
2021-06-23 14:55:42.123473: E tensorflow/core/lib/monitoring/collection_registry.cc:77] Cannot register 2 metrics with the same name: /tensorflow/core/saved_model/read/count
2021-06-23 14:55:42.123479: E tensorflow/core/lib/monitoring/collection_registry.cc:77] Cannot register 2 metrics with the same name: /tensorflow/core/saved_model/write/api
2021-06-23 14:55:42.123483: E tensorflow/core/lib/monitoring/collection_registry.cc:77] Cannot register 2 metrics with the same name: /tensorflow/core/saved_model/read/api
>>> a = tf. constant("Hello")
2021-06-23 14:55:50.641584: I tensorflow/core/platform/cpu_feature_guard.cc:142] This TensorFlow binary is optimized with oneAPI Deep Neural Network Library (oneDNN) to use the following CPU instructions
in performance-critical operations:  AVX2 AVX512F FMA
To enable them in other operations, rebuild TensorFlow with the appropriate compiler flags.
2021-06-23 14:55:55.019759: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1510] Created device /job:localhost/replica:0/task:0/device:GPU:0 with 6146 MB memory:  -> device: 0, name: Tesla V100-SXM2-3
2GB, pci bus id: 0000:18:00.0, compute capability: 7.0
2021-06-23 14:55:55.021090: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1510] Created device /job:localhost/replica:0/task:0/device:GPU:1 with 17445 MB memory:  -> device: 1, name: Tesla V100-SXM2-
32GB, pci bus id: 0000:3b:00.0, compute capability: 7.0
2021-06-23 14:55:55.022701: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1510] Created device /job:localhost/replica:0/task:0/device:GPU:2 with 30354 MB memory:  -> device: 2, name: Tesla V100-SXM2-
32GB, pci bus id: 0000:86:00.0, compute capability: 7.0
2021-06-23 14:55:55.024639: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1510] Created device /job:localhost/replica:0/task:0/device:GPU:3 with 30998 MB memory:  -> device: 3, name: Tesla V100-SXM2-
32GB, pci bus id: 0000:af:00.0, compute capability: 7.0
>>> b = tf.constant("World")
>>> ab = a+b
>>> print (ab)
tf.Tensor(b'HelloWorld', shape=(), dtype=string)
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
export NIX_PATH="nixpkgs=https://github.com/NixOS/nixpkgs/archive/nixos-21.05.tar.gz"
nix-shell --command 'python mnist.py'
```

Working combinations as of 24 June 2021
---------------------------------------

- Cuda 11.2, cuddn-8.1.1

pip install tensorflow

- Cuda 10.1, cudnn-7.6.3

default.nix: cudatoolkit_10_1 (in place of cudatoolkit_11)

pip install tensorflow==2.3


