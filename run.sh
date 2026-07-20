#!/usr/bin/bash

#SBATCH --job-name=run_hpl
#SBATCH -N 1
#SBATCH -n 8 #TODO: You can change this value for your experiment
#SBATCH -c 1
#SBATCH --time=00:05:00
#SBATCH --partition=cscamp

cd $HOME/HPL/hpl-2.3/bin/linux

source /share/cscamp/load_spack.sh
spack load openmpi@5.0.10 openblas@0.3.33

mpirun -np ${SLURM_NTASKS} ./xhpl
