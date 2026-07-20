#!/usr/bin/env -S bash

#SBATCH --job-name=compile-hpl
#SBATCH -o compile-hpl.log
#SBATCH -n 1
#SBATCH -c 8
#SBATCH --time=00:05:00
#SBATCH --partition=cscamp

date
cd $HOME

source /share/cscamp/load_spack.sh
spack load openmpi@5.0.10 openblas@0.3.33

cd ~/HPL

cp /share/cscamp/hpl-2.3.tar.gz .
tar xvf hpl-2.3.tar.gz && cd hpl-2.3/setup
sh make_generic
cd ../
cp ~/HPL/Make.linux .

make arch=linux

date
