#!/bin/bash
set -e

GIT_VERSION=2.43.0

# shellcheck source=image/functions.sh
source /hbb_build/functions.sh
# shellcheck source=image/activate_func.sh
source /hbb_build/activate_func.sh


SKIP_GIT=${SKIP_GIT:-true}



MAKE_CONCURRENCY=12

echo "Detected $MAKE_CONCURRENCY CPUs"
VARIANTS='shlib'
# VARIANTS='gc_hardened exe shlib'
export PATH=/hbb/bin:$PATH


### Git

if ! eval_bool "$SKIP_GIT"; then
	header "Installing Git $GIT_VERSION"
	download_and_extract git-$GIT_VERSION.tar.gz \
		git-$GIT_VERSION \
		https://www.kernel.org/pub/software/scm/git/git-$GIT_VERSION.tar.gz

	(
		activate_holy_build_box_deps_installation_environment
		set_default_cflags
		run make configure
		run ./configure --prefix=/hbb --without-tcltk
		run make -j$MAKE_CONCURRENCY
		run make install
		run strip --strip-all /hbb/bin/git
	)
	# shellcheck disable=SC2181
	if [[ "$?" != 0 ]]; then false; fi

	echo "Leaving source directory"
	popd >/dev/null
	run rm -rf git-$GIT_VERSION
fi

