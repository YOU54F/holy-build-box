#!/bin/bash
set -e


if [[ "$OPENSSL_1_1_LEGACY" = true ]]; then
	OPENSSL_VERSION=1.1.1w
else
	OPENSSL_VERSION=3.2.0
fi


# shellcheck source=image/functions.sh
source /hbb_build/functions.sh
# shellcheck source=image/activate_func.sh
source /hbb_build/activate_func.sh


SKIP_OPENSSL=${SKIP_OPENSSL:-true}

MAKE_CONCURRENCY=12

echo "Detected $MAKE_CONCURRENCY CPUs"
VARIANTS='shlib'
# VARIANTS='gc_hardened exe shlib'
export PATH=/hbb/bin:$PATH

### OpenSSL

function install_openssl()
{
	local VARIANT="$1"
	local PREFIX="/hbb_$VARIANT"

	header "Installing OpenSSL $OPENSSL_VERSION static libraries: $PREFIX"
	download_and_extract openssl-$OPENSSL_VERSION.tar.gz \
		openssl-$OPENSSL_VERSION \
		https://www.openssl.org/source/openssl-$OPENSSL_VERSION.tar.gz

	(
		set -o pipefail

		# shellcheck source=/dev/null
		source "$PREFIX/activate"

		# shellcheck disable=SC2030,SC2001
		CFLAGS=$(adjust_optimization_level "$STATICLIB_CFLAGS")
		export CFLAGS

		# shellcheck disable=SC2086
		run ./config --prefix="$PREFIX" --openssldir="$PREFIX/openssl" \
			threads zlib no-shared no-sse2 $CFLAGS $LDFLAGS
		run make -j$MAKE_CONCURRENCY
		run make install_sw
		run strip --strip-all "$PREFIX/bin/openssl"
		if [[ "$VARIANT" = exe_gc_hardened ]]; then
			run hardening-check -b "$PREFIX/bin/openssl"
		fi

		# shellcheck disable=SC2016
		if [ "$(uname -m)" = "x86_64" ] || [ "$(uname -m)" = "s390x" ]; then
			run sed -i 's/^Libs:.*/Libs: -L${libdir} -lcrypto -lz -ldl -lpthread/' "$PREFIX"/lib64/pkgconfig/libcrypto.pc
			run sed -i '/^Libs.private:.*/d' "$PREFIX"/lib64/pkgconfig/libcrypto.pc
		else
			run sed -i 's/^Libs:.*/Libs: -L${libdir} -lcrypto -lz -ldl -lpthread/' "$PREFIX"/lib/pkgconfig/libcrypto.pc
			run sed -i '/^Libs.private:.*/d' "$PREFIX"/lib/pkgconfig/libcrypto.pc
		fi
	)
	# shellcheck disable=SC2181
	if [[ "$?" != 0 ]]; then false; fi

	echo "Leaving source directory"
	popd >/dev/null
	run rm -rf openssl-$OPENSSL_VERSION
}

if ! eval_bool "$SKIP_OPENSSL"; then
	for VARIANT in $VARIANTS; do
		install_openssl "$VARIANT"
	done
	# run mv /hbb_exe_gc_hardened/bin/openssl /hbb/bin/
	run mv /hbb_shlib/bin/openssl /hbb/bin/
	for VARIANT in $VARIANTS; do
		run rm -f "/hbb_$VARIANT/bin/openssl"
	done
fi

