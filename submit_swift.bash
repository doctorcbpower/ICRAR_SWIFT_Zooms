#!/bin/bash
#PBS -q normal

#PBS -N SWIFT_zoom_APOSTLE_DMO
#PBS -P iv23
#PBS -j oe

#PBS -l ncpus=48
#PBS -l mem=192gb

#PBS -l walltime=4:00:00

#PBS -l storage=gdata/iv23+scratch/iv23

export OMP_NUM_THREADS=24
module load intel-compiler/2020.2.254
module load openmpi/4.1.0
module load intel-mkl/2020.2.254
module load fftw3/3.3.8 hdf5/1.10.5p gsl/2.6
module load intel-tbb/2020.2.254
module load parmetis/4.0.3-i8r8 metis/5.1.0-i8r8

export OMPI_MCA_btl=^openib
export OMPI_MCA_btl_openib_flags=1
export OMPI_MCA_plm_rsh_num_concurrent=768
export OMPI_MCA_mpool_rdma_rcache_size_limit=209715200

RUN_DIR=/scratch/iv23/cxp571/APOSTLE/
EXEC=swift_mpi
PARAMFILE=apostle.yml
RESTART= #--restart

ulimit -c unlimited 
cd ${RUN_DIR}

# Run 
mpirun_command="mpirun --x UCX_TLS=ud_x,shm,self -np $(($PBS_NCPUS/$OMP_NUM_THREADS)) --map-by node:PE=$OMP_NUM_THREADS --rank-by core --report-bindings"
args="--pin --cosmology --self-gravity ${RESTART} --threads=$OMP_NUM_THREADS"
executable=${RUN_DIR}/${EXEC}
params=${PARAMFILE} 
${mpirun_command} ${executable} ${args} ${params} > output_swift.log

