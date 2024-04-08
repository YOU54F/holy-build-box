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

if [[ "$OPENSSL_1_1_LEGACY" != true ]]; then
	mkdir -p /tmp/openssl
	pushd /tmp/openssl
	curl -O https://www.openssl.org/source/openssl-$OPENSSL_VERSION.tar.gz
	tar -zxf openssl-$OPENSSL_VERSION.tar.gz
	rm openssl-$OPENSSL_VERSION.tar.gz
	cd /tmp/openssl/openssl-$OPENSSL_VERSION
	if [ "$(uname -m)" = "x86_64" ]; then
		echo "detected processor"
		if grep -q "alpine" /etc/os-release; then
			echo "detected alpine"
			if file /bin/busybox | grep 32 >/dev/null; then
			echo "32 bit target"
			CONFIGURE_TARGET="linux-generic32 -m32 "
			fi
		fi
		elif grep -q "ubuntu" /etc/os-release; then
			echo "detected ubuntu"
			if file /bin/dash | grep 32 >/dev/null; then
			echo "32 bit target"
			CONFIGURE_TARGET="linux-generic32 -m32 "
		fi
	fi
	if [ "$(uname -m)" = "aarch64" ]; then
		./Configure no-afalgeng $CONFIGURE_TARGET--prefix=/usr/local/ssl --openssldir=/usr/local/ssl
	else
		./config $CONFIGURE_TARGET--prefix=/usr/local/ssl --openssldir=/usr/local/ssl
	fi
	make -j$MAKE_CONCURRENCY
	# make test
	make install_sw
	cd /
	rm -rf /tmp/openssl
	ln -s /usr/local/lib64/libssl.so.3 /usr/lib64/libssl.so.3 || echo true
	ln -s /usr/local/lib64/libcrypto.so.3 /usr/lib64/libcrypto.so.3 || echo true
	popd
fi