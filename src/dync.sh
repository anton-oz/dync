#!/bin/bash -e

if [[ -z "$HOME" ]]; then
	printf "\nno HOME varible set up, aborting\n"
	exit 1
fi

SYS_NAME=$(uname -s)

if [[ "$SYS_NAME" == "Linux" ]]; then
	BACKUPS="/var/local/dync/backups"
elif [[ "$SYS_NAME" == "Darwin" ]]; then
	BACKUPS="/Users/Shared/dync/backups"
else
	echo "Your system is not compatible with dync"
	exit 1
fi

# ugly but gets the absolute path of wherever dync is located
DYNC=$(realpath $(dirname $(dirname $BASH_SOURCE[0])))

DOTFILES="$DYNC/dotfiles"
LINKS="$DYNC/links"
SRC="$DYNC/src"

CONFIG_TARGET="$HOME/.config/"
HOME_TARGET="$HOME"
# DEV_CONFIG_TARGET="$DYNC/test_home/.config"
# DEV_HOME_TARGET="$DYNC/test_home"

# source colors and functions
. $SRC/colors.sh
. $SRC/functions.sh

# NOTE:
# default values for flag opts
RSYNCFLAGS="-qar"
CONFIRM=true
SILENT=false

# variables for setting rsync flags
s_set=false
v_set=false

flags_passed=false

# NOTE:
# if any args process them here

if [[ $# -eq 0 ]]; then
	showHelp
fi

if [[ $# -gt 0 ]]; then
	case $1 in
		-h|--help) showHelp ;;
		-V|--version) showVersion ;;
		# NOTE: flags here
		-S) syncFiles ;;
		-*) 
			while getopts ":yvs" opt; do
				case $opt in
					y) CONFIRM=false; flags_passed=true ;;
					v)
						if $s_set; then
							printf "$ERROR cannot set -s and -v at the same time\n"; exit 1
						fi
						flags_passed=true
						v_set=true
						RSYNCFLAGS="-var" ;;
					s)
						if $v_set; then
							printf "$ERROR cannot set -s and -v at the same time\n"; exit 1
						fi
						flags_passed=true
						s_set=true
						SILENT=true ;;
					\?) printf "unknown option: $1 \nuse dync --help to display options\n"; exit 1 ;;
				esac
			done 
			;;
		# *) printf "Unknown command: $1\nuse dync --help to display options\n"; exit 1;
		*) ;;
	esac
fi

command=$1
if [[ $flags_passed == true ]]; then
	command=$2
	shift
fi

# NOTE: commands here
case $command in
	add) addFile $@ ;;
	boot) bootstrap $@ ;;
	list) listFiles $@ ;;
	restore) restoreToBackup $@ ;;
	status) cd $DYNC && git status && cd - && exit 0 ;;
	sync) syncFiles $@ ;;
	*) echo "unknown option: $command" && showHelp && exit 1 ;; 
esac

