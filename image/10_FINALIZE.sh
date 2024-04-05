#!/bin/bash
set -e

SQLITE_VERSION=3450000
SQLITE_YEAR=2024

# shellcheck source=image/functions.sh
source /hbb_build/functions.sh
# shellcheck source=image/activate_func.sh
source /hbb_build/activate_func.sh

SKIP_FINALIZE=${SKIP_FINALIZE:-true}
VARIANTS='shlib'
# VARIANTS='gc_hardened exe shlib'
export PATH=/hbb/bin:$PATH

### Finalizing

if ! eval_bool "$SKIP_FINALIZE"; then
	header "Finalizing"
	run rm -rf /hbb/share/doc /hbb/share/man
	run rm -rf /hbb_build /tmp/*
	for VARIANT in $VARIANTS; do
		run rm -rf "/hbb_$VARIANT/share/doc" "/hbb_$VARIANT/share/man"
	done
fi
