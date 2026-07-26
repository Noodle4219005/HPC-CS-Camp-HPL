#!/usr/bin/env -S bash

#SBATCH --job-name=compile-hpl
#SBATCH -o compile-hpl.log
#SBATCH -n 1
#SBATCH -c 8
#SBATCH --time=00:05:00
#SBATCH --partition=camp

date
cd $HOME

source /share/hpc-camp/load_spack.sh
spack load openmpi@5.0.10 openblas@0.3.33

cd ~/HPL

cp /share/hpc-camp/hpl-2.3.tar.gz .
tar xvf hpl-2.3.tar.gz && cd hpl-2.3/setup
sh make_generic
cd ../
cp ~/HPL/Make.linux .

make arch=linux

# Build the tamper-resistant fair-use wrapper from its shc-obfuscated source.
# Only the compiled binary (~/HPL/hpl-wrapper) is used at run time; the enforced
# limits (<=4 processes, 90s runtime) live inside it and are not editable.
cc -O2 -o "$HOME/HPL/hpl-wrapper" "$HOME/HPL/.wrapper/hpl-wrapper.sh.x.c"
chmod 755 "$HOME/HPL/hpl-wrapper"

date
