#!/usr/bin/bash

#SBATCH --job-name=compile-openblas
#SBATCH --nodes=1
#SBATHC -c 8
#SBATCH --time=00:05:00
#SBATCH --partition=cscamp

exit

# FIXME: This script is no need to be used

date
cd $HOME

source /share/cscamp/load_spack.sh
spack load openmpi@5.0.10

cp /share/cscamp/OpenBLAS-0.3.29.tar.gz $HOME
tar xf OpenBLAS-0.3.29.tar.gz
cd OpenBLAS-0.3.29 && rm -fr build
mkdir -p build && cd build
CC=mpicc CXX=mpicxx FC=mpifort cmake .. -DCMAKE_INSTALL_PREFIX=$HOME/OpenBLAS-0.3.29/build
make install -j 8
date
