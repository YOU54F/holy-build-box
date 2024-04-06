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


	for VARIANT in $VARIANTS; do
		run mkdir -p "/hbb_$VARIANT"
		run cp /hbb_build/activate-exec "/hbb_$VARIANT/"
		run cp "/hbb_build/variants/$VARIANT.sh" "/hbb_$VARIANT/activate"
	done

	header "Updating system, installing compiler toolchain"
	if [[ "$(uname -s)" = "Linux" ]]; then
		if [[ -f "/etc/alpine-release" ]]; then
			if ! eval_bool "$SKIP_USERS_GROUPS"; then
				run addgroup -g 9327 builder
				run adduser -D -u 9327 -G builder builder
			fi

			run touch /var/lib/apk/*
			run apk update
			if [[ "$OPENSSL_1_1_LEGACY" = true ]]; then
				run apk add --no-cache tar curl curl-dev m4 autoconf automake libtool pkgconfig \
					file patch bzip2 zlib-dev gettext python2 py-setuptools python2-dev openssl-dev \
					epel centos-scl file
			else
				run apk add --no-cache tar curl curl-dev m4 autoconf automake libtool pkgconfig \
					file patch bzip2 zlib-dev gettext python3 python3-dev py-setuptools \
					perl build-base linux-headers openssl-dev openssl mpc1-dev xz python2 file
			fi
		elif [[ -f "/etc/debian_version" ]]; then
			run rm /etc/apt/sources.list
			echo "deb [trusted=yes] http://archive.debian.org/debian stretch main non-free contrib" > /etc/apt/sources.list
			echo 'deb-src [trusted=yes] http://archive.debian.org/debian/ stretch main non-free contrib'  >> /etc/apt/sources.list
			echo 'deb [trusted=yes] http://archive.debian.org/debian-security/ stretch/updates main non-free contrib'  >> /etc/apt/sources.list
			run cat /etc/apt/sources.list
			# run touch /var/lib/dpkg/*
			run apt-get update
			if [[ "$OPENSSL_1_1_LEGACY" = true ]]; then
				run apt-get install -y tar curl libcurl4-openssl-dev m4 autoconf automake libtool pkg-config \
					patch bzip2 zlib1g-dev gettext python3 python3-dev python-setuptools \
					perl build-essential linux-headers libssl-dev libmpc-dev xz-utils python2.7
			else
				run apt-get install -y tar curl libcurl4-openssl-dev m4 autoconf automake libtool pkg-config \
					patch bzip2 zlib1g-dev gettext python3 python3-dev python-setuptools \
					perl build-essential libssl-dev libmpc-dev xz-utils python2.7 wget gcc-9
			fi
			# pushd /opt
			# 	wget http://ftp.mirrorservice.org/sites/sourceware.org/pub/gcc/releases/gcc-9.3.0/gcc-9.3.0.tar.gz
			# 	tar zxf gcc-9.3.0.tar.gz
			# 	rm gcc-9.3.0.tar.gz
			# 	cd gcc-9.3.0
			# 	./contrib/download_prerequisites
			# 	./configure --disable-multilib
			# 	make -j $MAKE_CONCURRENCY
			# 	make install
			# popd
		elif [[ -f "/etc/centos-release" ]]; then
			if ! eval_bool "$SKIP_USERS_GROUPS"; then
				run groupadd -g 9327 builder
				run adduser --uid 9327 --gid 9327 builder
			fi
			header "Updating system, installing compiler toolchain"
			run touch /var/lib/rpm/*
			run yum update -y
			if [[ "$OPENSSL_1_1_LEGACY" = true ]]; then
				run yum install -y tar curl curl-devel m4 autoconf automake libtool pkgconfig \
					file patch bzip2 zlib-devel gettext python-setuptools python-devel openssl-devel \
					epel-release centos-release-scl
			else
				run yum install -y tar curl curl-devel m4 autoconf automake libtool pkgconfig \
					file patch bzip2 zlib-devel gettext python-setuptools python-devel \
					epel-release centos-release-scl perl perl-IPC-Cmd perl-Test-Simple
			fi
			run yum install -y python2-pip "devtoolset-$DEVTOOLSET_VERSION"

			echo "*link_gomp: %{static|static-libgcc|static-libstdc++|static-libgfortran: libgomp.a%s; : -lgomp } %{static: -ldl }" > /opt/rh/devtoolset-9/root/usr/lib/gcc/*-redhat-linux/9/libgomp.spec
			
		else
			echo "Unsupported Linux distribution"
		fi
	else
		echo "This script is intended to run on Linux"
	fi
fi