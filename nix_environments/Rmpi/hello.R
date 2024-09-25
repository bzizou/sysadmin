library(Rmpi)

id <- mpi.comm.rank(comm=0)
np <- mpi.comm.size(comm=0)
hostname <- mpi.get.processor.name()

msg <- sprintf ("Hello world from task %03d of %03d, on host %s \n", id , np , hostname)
cat(msg)

invisible(mpi.barrier(comm=0))
invisible(mpi.finalize())
