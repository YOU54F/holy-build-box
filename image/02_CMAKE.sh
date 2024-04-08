#!/bin/bash
set -e

if grep -q "ubuntu" /etc/os-release; then
	CMAKE_VERSION=3.22.2
	CMAKE_MAJOR_VERSION=3.22
else
	CMAKE_VERSION=3.28.1
	CMAKE_MAJOR_VERSION=3.28
fi

# # shellcheck source=image/functions.sh
source /hbb_build/functions.sh
# # shellcheck source=image/activate_func.sh
source /hbb_build/activate_func.sh

SKIP_CMAKE=${SKIP_CMAKE:-true}

MAKE_CONCURRENCY=12

# echo "Detected $MAKE_CONCURRENCY CPUs"
VARIANTS='shlib'
# # VARIANTS='gc_hardened exe shlib'
export PATH=/hbb/bin:$PATH

## CMake

if ! eval_bool "$SKIP_CMAKE"; then
	header "Installing CMake $CMAKE_VERSION"
	download_and_extract cmake-$CMAKE_VERSION.tar.gz \
		cmake-$CMAKE_VERSION \
		https://cmake.org/files/v$CMAKE_MAJOR_VERSION/cmake-$CMAKE_VERSION.tar.gz

	(
		activate_holy_build_box_deps_installation_environment
		set_default_cflags
		run ./configure --prefix=/hbb --no-qt-gui --parallel=$MAKE_CONCURRENCY
		run make -j$MAKE_CONCURRENCY
		run make install
		run strip --strip-all /hbb/bin/cmake /hbb/bin/cpack /hbb/bin/ctest
	)
	# shellcheck disable=SC2181
	if [[ "$?" != 0 ]]; then false; fi

	echo "Leaving source directory"
	popd >/dev/null
	run rm -rf cmake-$CMAKE_VERSION
fi
