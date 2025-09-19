#!/bin/bash -e

##
# Check for home and dync env variables, quit the
# script if they do not exist as this script requires
# those.
##

if [[ -z "$HOME" ]]; then
	printf "\nno HOME varible set up, aborting\n"
	exit 1
fi

if [[ -z "$DYNC" ]]; then
	printf "no DYNC variable set up, aborting\n"
	exit 1
fi

##
# Check what system dync is running on, and assign backups
# variable to correct directory.
##

SYS_NAME=$(uname -s)

if [[ "$SYS_NAME" == "Linux" ]]; then
	BACKUPS="/var/local/dync/backups"
elif [[ "$SYS_NAME" == "Darwin" ]]; then
	BACKUPS="/Users/Shared/dync/backups"
else
	echo "Your system is not compatible with dync"
	exit 1
fi

##
# path varibles for later use in dyncs logic.
##

DOTFILES="$DYNC/dotfiles"
LINKS="$DYNC/links"
SRC="$DYNC/src"

CONFIG_TARGET="$HOME/.config"
# CONFIG_TARGET="$DYNC/test_home/.config"
HOME_TARGET="$HOME"
# HOME_TARGET="$DYNC/test_home"

##
# TODO:
# set up tests for dync
##
# DEV_CONFIG_TARGET="$DYNC/test_home/.config"
# DEV_HOME_TARGET="$DYNC/test_home"
##

##
# Source colors and functions.
##
. $SRC/colors.sh
. $SRC/functions.sh

##
# default values for flag opts
##
RSYNCFLAGS="-qar"
SILENT=false

##
# variables for setting rsync flags
##
s_set=false
v_set=false

flags_passed=false

##
# If no arguments, show help menu.
##
if [[ $# -eq 0 ]]; then
	showHelp
fi

if [[ $# -gt 0 ]]; then
	case $1 in
		-h|--help) showHelp ;;
		-V|--version) showVersion ;;
		# NOTE: flags here
		-*) 
			while getopts ":yvs" opt; do
				case $opt in
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
	remove|rm) removeFile $@ ;;
	boot) bootstrap $@ ;;
	backup) backup ;;
	list) listFiles $@ ;;
	restore) restoreToBackup $@ ;;
	status) showStatus ;;
	sync) syncFiles $@ ;;
	*) echo "unknown command: $command" && showHelp && exit 1 ;; 
esac
