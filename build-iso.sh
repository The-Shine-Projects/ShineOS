#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
cd "$ROOT"
PATH=/usr/sbin:/sbin:$PATH
export PATH

if [ "$(id -u)" -ne 0 ]; then
	echo "Live-build needs root package ownership. Run: sudo $ROOT/build-iso.sh" >&2
	exit 2
fi

available_kib=$(df -Pk "$ROOT" | awk 'NR == 2 { print $4 }')
required_kib=$((16 * 1024 * 1024))
if [ "$available_kib" -lt "$required_kib" ]; then
	echo "Need at least 16 GiB free in $ROOT's filesystem; currently available: $((available_kib / 1024 / 1024)) GiB." >&2
	exit 2
fi

cpu=$(python3 -c 'import os; print(min(os.sched_getaffinity(0)))')
if [ "$#" -ne 0 ]; then
	echo "Usage: sudo $ROOT/build-iso.sh" >&2
	exit 2
fi
work=$(mktemp -d "${TMPDIR:-/tmp}/shineos-live-build.XXXXXX")
echo "Build workspace: $work"
cp -a "$ROOT/config" "$work/config"
if [ -d "$ROOT/auto" ]; then
	cp -a "$ROOT/auto" "$work/auto"
fi
(
	cd "$work"
	lb config
)
echo "Building ShineOS for Debian Trixie on CPU $cpu with gzip level 1."
(cd "$work" && taskset -c "$cpu" lb build)

iso=$(find "$work" -maxdepth 2 -type f -name '*.iso' -print -quit)
if [ -z "$iso" ]; then
	echo "Build finished without a top-level ISO; inspect $work" >&2
	exit 1
fi
mkdir -p "$ROOT/output"
cp -f "$iso" "$ROOT/output/"
echo "ISO created: $ROOT/output/$(basename "$iso")"
