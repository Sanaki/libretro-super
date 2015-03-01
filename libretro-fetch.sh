#! /usr/bin/env bash
# vim: set ts=3 sw=3 noet ft=sh : bash

SCRIPT="${0#./}"
BASE_DIR="${SCRIPT%/*}"
WORKDIR="$PWD"

if [ "$BASE_DIR" = "$SCRIPT" ]; then
	BASE_DIR="$WORKDIR"
else
	if [[ "$0" != /* ]]; then
		# Make the path absolute
		BASE_DIR="$WORKDIR/$BASE_DIR"
	fi
fi

. "$BASE_DIR/libretro-config.sh"
. "$BASE_DIR/script-modules/util.sh"
. "$BASE_DIR/script-modules/fetch-rules.sh"

# Rules for fetching cores are in this file:
. "$BASE_DIR/core-rules.sh"

# libretro_fetch: Download the given core using its fetch rules
#
# $1	Name of the core to fetch
libretro_fetch() {
	local module_name
	local module_dir
	local fetch_rule
	local post_fetch_cmd

	eval "module_name=\$libretro_${1}_name"
	[ -z "$module_name" ] && module_name="$1"
	echo "=== $module_name"

	eval "fetch_rule=\$libretro_${1}_fetch_rule"
	[ -z "$fetch_rule" ] && fetch_rule=fetch_git

	eval "module_dir=\$libretro_${1}_dir"
	[ -z "$module_dir" ] && module_dir="libretro-$1"

	case "$fetch_rule" in
		fetch_git)
			local git_url
			local git_submodules
			eval "git_url=\$libretro_${1}_git_url"
			if [ -z "$git_url" ]; then
				echo "libretro_fetch:No URL set to fetch $1 via git."
				exit 1
			fi

			eval "git_submodules=\$libretro_${1}_git_submodules"

			# TODO: Don't depend on fetch_rule being git
			echo "Fetching ${1}..."
			$fetch_rule "$git_url" "$module_dir" $git_submodules
			;;
		*)
			echo "libretro_fetch:Unknown fetch rule for $1: \"$fetch_rule\"."
			exit 1
			;;
	esac

	eval "post_fetch_cmd=\$libretro_${1}_post_fetch_cmd"
	if [ -n "$post_fetch_cmd" ]; then
		echo_cmd "cd \"$WORKDIR/$module_dir\""
		echo_cmd "$post_fetch_cmd"
	fi
}

fetch_devkit() {
	echo "=== libretro Developer's Kit"
	echo "Fetching the libretro devkit..."
	fetch_git "https://github.com/libretro/libretro-manifest.git" "libretro-manifest"
	fetch_git "https://github.com/libretro/libretrodb.git" "libretrodb"
	fetch_git "https://github.com/libretro/libretro-dat-pull.git" "libretro-dat-pull"
	fetch_git "https://github.com/libretro/libretro-common.git" "libretro-common"
}


if [ -n "$1" ]; then
	while [ -n "$1" ]; do
		case "$1" in
			fetch_devkit)
				# These don't have rule-based fetch yet.
				$1
				;;
			fetch_libretro_*)
				# "Old"-style
				$1
				;;
			*)
				# New style (just cores for now)
				libretro_fetch $1
				;;
		esac
		shift
	done
else
	libretro_fetch retroarch
	fetch_devkit

	libretro_fetch bsnes
	libretro_fetch snes9x
	libretro_fetch snes9x_next
	libretro_fetch genesis_plus_gx
	libretro_fetch fb_alpha
	libretro_fetch vba_next
	libretro_fetch vbam
	libretro_fetch handy
	libretro_fetch bnes
	libretro_fetch fceumm
	libretro_fetch gambatte
	libretro_fetch meteor
	libretro_fetch nxengine
	libretro_fetch prboom
	libretro_fetch stella
	libretro_fetch desmume
	libretro_fetch quicknes
	libretro_fetch nestopia
	libretro_fetch tyrquake
	libretro_fetch pcsx_rearmed
	libretro_fetch mednafen_gba
	libretro_fetch mednafen_lynx
	libretro_fetch mednafen_ngp
	libretro_fetch mednafen_pce_fast
	libretro_fetch mednafen_supergrafx
	libretro_fetch mednafen_psx
	libretro_fetch mednafen_pcfx
	libretro_fetch mednafen_snes
	libretro_fetch mednafen_vb
	libretro_fetch mednafen_wswan
	libretro_fetch scummvm
	libretro_fetch yabause
	libretro_fetch dosbox
	libretro_fetch virtualjaguar
	libretro_fetch mame078
	libretro_fetch mame139
	libretro_fetch mame
	libretro_fetch ffmpeg
	libretro_fetch bsnes_cplusplus98
	libretro_fetch bsnes_mercury
	libretro_fetch picodrive
	libretro_fetch tgbdual
	libretro_fetch mupen64plus
	libretro_fetch dinothawr
	libretro_fetch uae
	libretro_fetch 3dengine
	libretro_fetch remotejoy
	libretro_fetch bluemsx
	libretro_fetch fmsx
	libretro_fetch 2048
	libretro_fetch vecx
	libretro_fetch ppsspp
	libretro_fetch prosystem
	libretro_fetch o2em
	libretro_fetch 4do
	libretro_fetch catsfc
	libretro_fetch stonesoup
	libretro_fetch hatari
	libretro_fetch tempgba
	libretro_fetch gpsp
	libretro_fetch emux
	libretro_fetch fuse
fi
