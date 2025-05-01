#!/bin/bash -e

if [[ ! "$HOME" ]]; then
	printf "\nno HOME varible set up, aborting\n"
	exit 1
fi

# ugly but gets the absolute path of wherever dync is located
DYNC=$(realpath $(dirname $(dirname $BASH_SOURCE[0])))

DOTFILES="$DYNC/dotfiles"
BACKUPS="$DYNC/backups"
SRC="$DYNC/src"

# CONFIG_TARGET="$HOME/.config/"
# HOME_TARGET="$HOME"
DEV_CONFIG_TARGET="$DYNC/test_home/.config"
DEV_HOME_TARGET="$DYNC/test_home"

# source colors and functions
. $SRC/colors.sh
. $SRC/functions.sh

# NOTE:
# default values for flag opts
RSYNCFLAGS="-qar"
CONFIRM=true
SILENT=false

# NOTE:
# if any args process them here
if [[ $# -gt 0 ]]; then
	case $1 in
		-h|--help) showHelp ;;
		# NOTE: commands here
		add) addFile $@ ;;
		list) listFiles $@ ;;
		# NOTE: flags here
		-*) 
			while getopts ":yvs" opt; do
				case $opt in
					y) CONFIRM=false ;;
					v) RSYNCFLAGS="-var" ;;
					s) SILENT=true ;;
					\?) printf "unknown option: $1 \nuse dync --help to display options\n"; exit 1 ;;
				esac
			done 
			;;
		*) printf "Unknown command: $1\nuse dync --help to display options\n"; exit 1;
	esac
fi

# NOTE:
# process flags if neccesary
if $CONFIRM; then
	confirmPrompt
fi

cd $DYNC

BACKUP_SUCCESS_MESSAGE=""
if [[ $(ls -1a test_home | wc -l) -gt 2 ]]; then
	backup
fi

copyDotfiles

if $SILENT; then
	exit 0
fi
printf "${BACKUP_SUCCESS_MESSAGE}\n"
printf "${SUCCESS}  dynced  ${NC}\n"

