#!/bin/bash
set -e
# shellcheck source=image/functions.sh
source /hbb_build/functions.sh
# shellcheck source=image/activate_func.sh
source /hbb_build/activate_func.sh

SKIP_INITIALIZE=${SKIP_INITIALIZE:-false}
SKIP_USERS_GROUPS=${SKIP_USERS_GROUPS:-false}

MAKE_CONCURRENCY=12

echo "Detected $MAKE_CONCURRENCY CPUs"
VARIANTS='shlib'
# VARIANTS='gc_hardened exe shlib'
export PATH=/hbb/bin:$PATH

#########################

if ! eval_bool "$SKIP_INITIALIZE"; then
	header "Initializing"
	run mkdir -p /hbb /hbb/bin
	run cp /hbb_build/libcheck /hbb/bin/
	run cp /hbb_build/hardening-check /hbb/bin/
	run cp /hbb_build/setuser /hbb/bin/
	run cp /hbb_build/activate_func.sh /hbb/activate_func.sh
	run cp /hbb_build/hbb-activate /hbb/activate
	run cp /hbb_build/activate-exec /hbb/activate-exec

	if ! eval_bool "$SKIP_USERS_GROUPS"; then
		run addgroup -g 9327 builder
		run adduser -D -u 9327 -G builder builder
	fi

	for VARIANT in $VARIANTS; do
		run mkdir -p "/hbb_$VARIANT"
		run cp /hbb_build/activate-exec "/hbb_$VARIANT/"
		run cp "/hbb_build/variants/$VARIANT.sh" "/hbb_$VARIANT/activate"
	done

	header "Updating system, installing compiler toolchain"
	run touch /var/lib/apk/*
	run apk update
	if [[ "$OPENSSL_1_1_LEGACY" = true ]]; then
		run apk add --no-cache tar curl curl-dev m4 autoconf automake libtool pkgconfig \
			file patch bzip2 zlib-dev gettext python2 py-setuptools python2-dev openssl-dev \
			epel centos-scl
	else
		run apk add --no-cache tar curl curl-dev m4 autoconf automake libtool pkgconfig \
			file patch bzip2 zlib-dev gettext python3 python3-dev py-setuptools \
			perl build-base linux-headers openssl-dev openssl mpc1-dev xz python2
	fi
	# run apk add --no-cache "gcc"

	# echo "*link_gomp: %{static|static-libgcc|static-libstdc++|static-libgfortran: libgomp.a%s; : -lgomp } %{static: -ldl }" > /opt/rh/devtoolset-9/root/usr/lib/gcc/*-redhat-linux/9/libgomp.spec

fi


