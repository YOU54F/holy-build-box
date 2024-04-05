#!/bin/bash
set -e


ZLIB_VERSION=1.3


# shellcheck source=image/functions.sh
source /hbb_build/functions.sh
# shellcheck source=image/activate_func.sh
source /hbb_build/activate_func.sh


SKIP_ZLIB=${SKIP_ZLIB:-true}

MAKE_CONCURRENCY=12

echo "Detected $MAKE_CONCURRENCY CPUs"
VARIANTS='shlib'
# VARIANTS='gc_hardened exe shlib'
export PATH=/hbb/bin:$PATH


### zlib

function install_zlib()
{
	local VARIANT="$1"
	local PREFIX="/hbb_$VARIANT"

	header "Installing zlib $ZLIB_VERSION static libraries: $VARIANT"
	download_and_extract zlib-$ZLIB_VERSION.tar.gz \
		zlib-$ZLIB_VERSION \
		https://zlib.net/fossils/zlib-$ZLIB_VERSION.tar.gz

	(
		# shellcheck source=/dev/null
		source "$PREFIX/activate"
		# shellcheck disable=SC2030,SC2031
		CFLAGS=$(adjust_optimization_level "$STATICLIB_CFLAGS")
		export CFLAGS
		run ./configure --prefix="$PREFIX" --static
		run make -j$MAKE_CONCURRENCY
		run make install
	)
	# shellcheck disable=SC2181
	if [[ "$?" != 0 ]]; then false; fi

	echo "Leaving source directory"
	popd >/dev/null
	run rm -rf zlib-$ZLIB_VERSION
}

if ! eval_bool "$SKIP_ZLIB"; then
	for VARIANT in $VARIANTS; do
		install_zlib "$VARIANT"
	done
fi

