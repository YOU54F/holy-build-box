#!/bin/bash
set -e

SQLITE_VERSION=3450000
SQLITE_YEAR=2024

# shellcheck source=image/functions.sh
source /hbb_build/functions.sh
# shellcheck source=image/activate_func.sh
source /hbb_build/activate_func.sh

SKIP_SQLITE=${SKIP_SQLITE:-true}

MAKE_CONCURRENCY=12

echo "Detected $MAKE_CONCURRENCY CPUs"
VARIANTS='shlib'
# VARIANTS='gc_hardened exe shlib'
export PATH=/hbb/bin:$PATH


### SQLite

function install_sqlite()
{
	local VARIANT="$1"
	local PREFIX="/hbb_$VARIANT"

	header "Installing SQLite $SQLITE_VERSION static libraries: $PREFIX"
	download_and_extract sqlite-autoconf-$SQLITE_VERSION.tar.gz \
		sqlite-autoconf-$SQLITE_VERSION \
		https://www.sqlite.org/$SQLITE_YEAR/sqlite-autoconf-$SQLITE_VERSION.tar.gz

	(
		# shellcheck source=/dev/null
		source "$PREFIX/activate"
		# shellcheck disable=SC2031
		CFLAGS=$(adjust_optimization_level "$STATICLIB_CFLAGS")
		# shellcheck disable=SC2031
		CXXFLAGS=$(adjust_optimization_level "$STATICLIB_CXXFLAGS")
		export CFLAGS
		export CXXFLAGS
		run ./configure --prefix="$PREFIX" --enable-static \
			--disable-shared --disable-dynamic-extensions
		run make -j$MAKE_CONCURRENCY
		run make install
		if [[ "$VARIANT" = exe_gc_hardened ]]; then
			run hardening-check -b "$PREFIX/bin/sqlite3"
		fi
		run strip --strip-all "$PREFIX/bin/sqlite3"
	)
	# shellcheck disable=SC2181
	if [[ "$?" != 0 ]]; then false; fi

	echo "Leaving source directory"
	popd >/dev/null
	run rm -rf sqlite-autoconf-$SQLITE_VERSION
}

if ! eval_bool "$SKIP_SQLITE"; then
	for VARIANT in $VARIANTS; do
		install_sqlite "$VARIANT"
	done
	# run mv /hbb_exe_gc_hardened/bin/sqlite3 /hbb/bin/
	run mv /hbb_shlib/bin/sqlite3 /hbb/bin/
	for VARIANT in $VARIANTS; do
		run rm -f "/hbb_$VARIANT/bin/sqlite3"
	done
fi
