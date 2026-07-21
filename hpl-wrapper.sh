#!/usr/bin/env bash

set -euo pipefail

usage() {
    printf 'Usage: %s N NB P Q\n' "${0##*/}"
}

if (( $# == 1 )) && [[ $1 == -h || $1 == --help ]]; then
    usage
    exit 0
fi

if (( $# != 4 )); then
    usage >&2
    exit 2
fi

names=(N NB P Q)
values=("$@")
for index in "${!names[@]}"; do
    if [[ ! ${values[$index]} =~ ^[1-9][0-9]*$ ]]; then
        printf '%s must be a positive integer: %s\n' \
            "${names[$index]}" "${values[$index]}" >&2
        exit 2
    fi
done

readonly n=$1
readonly nb=$2
readonly p=$3
readonly q=$4
readonly ranks=$((p * q))
readonly hpl_dir="$HOME/HPL/hpl-2.3/bin/linux"
readonly hpl_dat="$hpl_dir/HPL.dat"
readonly xhpl="$hpl_dir/xhpl"
readonly spack_setup=/share/cscamp/load_spack.sh

if [[ ! -f $hpl_dat || ! -w $hpl_dat ]]; then
    printf 'HPL.dat is missing or not writable: %s\n' "$hpl_dat" >&2
    exit 1
fi

if [[ ! -x $xhpl ]]; then
    printf 'HPL executable is missing or not executable: %s\n' "$xhpl" >&2
    exit 1
fi

if [[ ! -r $spack_setup ]]; then
    printf 'Spack setup script is not readable: %s\n' "$spack_setup" >&2
    exit 1
fi

source "$spack_setup"
spack load openmpi@5.0.10 openblas@0.3.33

if ! command -v mpirun >/dev/null 2>&1; then
    printf 'mpirun is not available after loading Spack packages\n' >&2
    exit 1
fi

temp_dat=$(mktemp "$hpl_dat.XXXXXX")
cleanup() {
    [[ -z ${temp_dat:-} ]] || rm -f "$temp_dat"
}
trap cleanup EXIT

if ! awk -v n="$n" -v nb="$nb" -v p="$p" -v q="$q" '
    NR == 4  { printf "%-12s device out (6=stdout,7=stderr,file)\n", 6; next }
    NR == 5  { printf "%-12s # of problems sizes (N)\n", 1; next }
    NR == 6  { printf "%-12s Ns\n", n; next }
    NR == 7  { printf "%-12s # of NBs\n", 1; next }
    NR == 8  { printf "%-12s NBs\n", nb; next }
    NR == 10 { printf "%-12s # of process grids (P x Q)\n", 1; next }
    NR == 11 { printf "%-12s Ps\n", p; next }
    NR == 12 { printf "%-12s Qs\n", q; next }
    { print }
    END { if (NR < 12) exit 1 }
' "$hpl_dat" >"$temp_dat"; then
    printf 'HPL.dat has an invalid format: %s\n' "$hpl_dat" >&2
    exit 1
fi

chmod --reference="$hpl_dat" "$temp_dat"
mv "$temp_dat" "$hpl_dat"
temp_dat=

cd "$hpl_dir"
exec mpirun -np "$ranks" --oversubscribe ./xhpl
