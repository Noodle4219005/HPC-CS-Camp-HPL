#!/usr/bin/env -S bash

#SBATCH --job-name=run_hpl
#SBATCH -o run_hpl.log
#SBATCH -N 1
#SBATCH -c 1
#SBATCH --time=00:05:00
#SBATCH --partition=cscamp

export PATH="$HOME/HPL/:$PATH"

# Initialize variables with default values
N=4096
NB=64
P=2
Q=2

# Display help message
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "  -n, -N   VALUE       Set the N  value"
    echo "  -nb, -NB VALUE       Set the NB value"
    echo "  -p, -P   VALUE       Set the P  value"
    echo "  -q, -Q   VALUE       Set the Q  value"
    exit 1
}

# Parse options
while [[ $# -gt 0 ]]; do
    case "$1" in
        -n|-N)
            N="$2"
            shift 2 # Move past flag and value
            ;;
        -nb|-NB)
            NB="$2"
            shift 2 # Move past flag and value
            ;;
        -p|-P)
            P="$2"
            shift 2 # Move past flag
            ;;
        -q|-Q)
            Q="$2"
            shift 2 # Move past flag
            ;;
        -h|-H)
            usage
            ;;
        *)
            echo "Error: Invalid option '$1'" >&2
            usage
            ;;
    esac
done

# Number of MPI processes is fully determined by the process grid.
NP=$((P * Q))

# When we are not yet running inside a right-sized allocation, resubmit
# ourselves asking Slurm for exactly P*Q tasks. The sentinel prevents an
# infinite resubmit loop; when sbatch is unavailable (e.g. GPU4 native) we
# simply fall through and run directly.
if [[ -z "${HPL_AUTOSUBMIT:-}" ]] && command -v sbatch >/dev/null 2>&1; then
    exec sbatch --ntasks="$NP" --export=ALL,HPL_AUTOSUBMIT=1 \
        "$0" -n "$N" -nb "$NB" -p "$P" -q "$Q"
fi

# Run through the compiled, tamper-resistant wrapper. It enforces the camp
# fair-use limits (at most 4 MPI processes and a 90-second runtime cap); those
# constraints live inside the binary and cannot be edited here.
readonly wrapper_bin="$HOME/HPL/hpl-wrapper"
if [[ ! -x "$wrapper_bin" ]]; then
    echo "Error: compiled wrapper not found at $wrapper_bin." >&2
    echo "Build it first with: sbatch hpl.sh" >&2
    exit 1
fi

exec "$wrapper_bin" "$N" "$NB" "$P" "$Q"
