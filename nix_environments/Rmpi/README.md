Fix for Rmpi not finding mpi_universe_size
==========================================

Testing:

```
nix develop
mpirun -np 4 Rscript hello.R
```
