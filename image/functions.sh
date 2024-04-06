# shellcheck shell=bash

RESET=$'\e[0m'
BOLD=$'\e[1m'
YELLOW=$'\e[33m'
BLUE_BG=$'\e[44m'

function header()
{
	local title="$1"
	echo
	echo "${BLUE_BG}${YELLOW}${BOLD}${title}${RESET}"
	echo "------------------------------------------"
}

function run()
{
	echo "+ $*"
	"$@"
}

function download_and_extract()
{
	local BASENAME="$1"
	local DIRNAME="$2"
	local URL="$3"
	local regex='\.bz2$'
	local zipregex='\.zip$'

	if [[ ! -e "/tmp/$BASENAME" ]]; then
		run rm -f "/tmp/$BASENAME.tmp"
		run curl --fail -L -o "/tmp/$BASENAME.tmp" "$URL"
		run mv "/tmp/$BASENAME.tmp" "/tmp/$BASENAME"
	fi
	if [[ "$URL" =~ $regex ]]; then
		run tar xjf "/tmp/$BASENAME"
	elif [[ "$URL" =~ $zipregex ]]; then
		run unzip "/tmp/$BASENAME" -d /$DIRNAME
	else
		run tar xzf "/tmp/$BASENAME"
	fi

	echo "Entering $RUNTIME_DIR/$DIRNAME"
	# shellcheck disable=SC2164
	pushd "$DIRNAME" >/dev/null
}

function eval_bool()
{
	local VAL="$1"
	[[ "$VAL" = 1 || "$VAL" = true || "$VAL" = yes || "$VAL" = y ]]
}

function set_default_cflags()
{
	# shellcheck disable=SC2030
	CFLAGS=$(adjust_optimization_level "-O2")
	CXXFLAGS="$CFLAGS"
	export CFLAGS
	export CXXFLAGS
}

# Given a string containing compiler flags, adjusts optimization level flags according
# to global settings.
function adjust_optimization_level()
{
	local VAL="$1"
	if eval_bool "$DISABLE_OPTIMIZATIONS"; then
		# shellcheck disable=SC2001
		sed 's|-O[0-9]*||g' <<<"$VAL"
	else
		echo "$VAL"
	fi
}
