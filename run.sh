#!/usr/bin/env -S bash

#SBATCH --job-name=run_hpl
#SBATCH -o run_hpl.log
#SBATCH -N 1
#SBATCH -n 8 #TODO: You can change this value for your experiment
#SBATCH -c 1
#SBATCH --time=00:05:00
#SBATCH --partition=cscamp

export PATH="$HOME/HPL/:$PATH"

#TODO: Try to change the following values
#NOTE: 注意等於符號(=)的前後都不能有空格
N=4096
NB=64
P=4
Q=2

hpl-wrapper.sh $N $NB $P $Q
