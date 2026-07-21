# HPC-Summer-Camp-HPL

## Installation
1. Change directory to home: `cd ~`
2. Clone the repository: `git clone https://github.com/NTHU-SC/HPC-Summer-Camp-HPL.git HPL`
3. `cd HPL`
4. Install openblas: `sbatch ./openblas.sh`
5. Build HPL: `sbatch ./hpl.sh`

## Run
1. Modify `~/HPL/hpl-2.3/bin/linux/HPL.dat`
2. `cd ~/HPL/hpl-2.3/bin/linux`
3. Run: `sbatch ~/HPL/run.sh`

To run one parameter set and print the HPL result to stdout:
```bash
~/HPL/hpl-wrapper.sh N NB P Q
```
The wrapper keeps one value for each of `N`, `NB`, `P`, and `Q` in `HPL.dat`,
sets the HPL output device to stdout, and launches `P * Q` MPI processes.

## Submit
1. Create a new directory for the judge: `mkdir -p ~/.hpc_camp`
2. If you are the first time to submit, run: `echo "export PATH=\$PATH:/project/ACD114003/bin/" >> ~/.bashrc && source ~/.bashrc`
3. Submit: `hpl-judge`
