#!/bin/bash
set -e


if [[ "$OPENSSL_1_1_LEGACY" = true ]]; then
	OPENSSL_VERSION=1.1.1w
else
	OPENSSL_VERSION=3.6.0
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

if [[ "$OPENSSL_1_1_LEGACY" != true ]]; then
	header "Building OpenSSL $OPENSSL_VERSION from source for CMake"
	activate_holy_build_box_deps_installation_environment
	set_default_cflags
	mkdir -p /tmp/openssl
	pushd /tmp/openssl
	curl -LO https://www.openssl.org/source/openssl-$OPENSSL_VERSION.tar.gz
	tar -zxf openssl-$OPENSSL_VERSION.tar.gz
	rm openssl-$OPENSSL_VERSION.tar.gz
	cd /tmp/openssl/openssl-$OPENSSL_VERSION
	if [ "$(uname -m)" = "aarch64" ]; then
		./Configure no-afalgeng
	else
		./config
	fi
	make -j$MAKE_CONCURRENCY
	# make test
	make install_sw
	cd /
	rm -rf /tmp/openssl
	if grep -qi alpine /etc/os-release; then
	echo "Alpine detected, creating symlinks for OpenSSL 3"
		# ln -s /usr/local/lib/libssl.so.3 /usr/lib/libssl.so.3
		# ln -s /usr/local/lib/libcrypto.so.3 /usr/lib/libcrypto
		# ln -s /usr/local/lib/libssl.so.3 /usr/lib64/libssl.so.3
		# ln -s /usr/local/lib/libcrypto.so.3 /usr/lib64/libcrypto.so.3
	else
		ln -s /usr/local/lib64/libssl.so.3 /usr/lib64/libssl.so.3
		ln -s /usr/local/lib64/libcrypto.so.3 /usr/lib64/libcrypto.so.3
	fi
	popd
fi