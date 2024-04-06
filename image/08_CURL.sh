#!/bin/bash
set -e

CCACHE_VERSION=4.9
CMAKE_VERSION=3.28.1
CMAKE_MAJOR_VERSION=3.28
GCC_LIBSTDCXX_VERSION=9.3.0
ZLIB_VERSION=1.3
if [[ "$OPENSSL_1_1_LEGACY" = true ]]; then
	OPENSSL_VERSION=1.1.1w
else
	OPENSSL_VERSION=3.2.0
fi
CURL_VERSION=8.5.0
GIT_VERSION=2.43.0
SQLITE_VERSION=3450000
SQLITE_YEAR=2024

# shellcheck source=image/functions.sh
source /hbb_build/functions.sh
# shellcheck source=image/activate_func.sh
source /hbb_build/activate_func.sh

SKIP_CURL=${SKIP_CURL:-true}

MAKE_CONCURRENCY=12

echo "Detected $MAKE_CONCURRENCY CPUs"
VARIANTS='shlib'
# VARIANTS='gc_hardened exe shlib'
export PATH=/hbb/bin:$PATH


### libcurl

function install_curl()
{
	local VARIANT="$1"
	local PREFIX="/hbb_$VARIANT"

	header "Installing Curl $CURL_VERSION static libraries: $PREFIX"
	download_and_extract curl-$CURL_VERSION.tar.bz2 \
		curl-$CURL_VERSION \
		https://curl.se/download/curl-$CURL_VERSION.tar.bz2

	(
		# shellcheck source=/dev/null
		source "$PREFIX/activate"
		# shellcheck disable=SC2030,SC2031
		CFLAGS=$(adjust_optimization_level "$STATICLIB_CFLAGS")
		export CFLAGS
		./configure --prefix="$PREFIX" --disable-shared --disable-debug --enable-optimize --disable-werror \
			--disable-curldebug --enable-symbol-hiding --disable-ares --disable-manual --disable-ldap --disable-ldaps \
			--disable-rtsp --disable-dict --disable-ftp --disable-gopher --disable-imap \
			--disable-pop3 --without-librtmp --disable-smtp --disable-smtps \
			--disable-telnet --disable-tftp --disable-smb --disable-versioned-symbols \
			--without-libidn2 --without-libssh2 --without-nghttp2 \
			--with-ssl
		run make -j$MAKE_CONCURRENCY
		run make install
		if [[ "$VARIANT" = exe_gc_hardened ]]; then
			run hardening-check -b "$PREFIX/bin/curl"
		fi
		run rm -f "$PREFIX/bin/curl"
	)
	# shellcheck disable=SC2181
	if [[ "$?" != 0 ]]; then false; fi

	echo "Leaving source directory"
	popd >/dev/null
	run rm -rf curl-$CURL_VERSION
}

if ! eval_bool "$SKIP_CURL"; then
	for VARIANT in $VARIANTS; do
		install_curl "$VARIANT"
	done
fi

