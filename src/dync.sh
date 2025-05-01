#!/bin/bash -e

if [[ ! "$HOME" ]]; then
	printf "\nno HOME varible set up, aborting\n\n"
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

# NOTE:
# default values for flag opts
RSYNCFLAGS="-var"
CONFIRM=true
SILENT=false

while getopts "yqs" opt; do
	case $opt in
		y) CONFIRM=false ;;
		q) RSYNCFLAGS="-qar" ;;
		s) RSYNCFLAGS="-qar"; SILENT=true ;;
		*) printf "unknown flag: $opt \nuse dync --help to display options\n"; exit 1 ;;
	esac
done

# source colors and functions
. $SRC/colors.sh
. $SRC/functions.sh


# NOTE: 
# process commands
if [[ $1 == 'list' ]]; then
	shift
	listFiles $@
fi

if [[ $1 == 'add' ]]; then
	addFile $@
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
wait
if $SILENT; then
	exit 0
fi
printf "${BACKUP_SUCCESS_MESSAGE}\n"
printf "${SUCCESS}  dynced  ${NC}\n\n"

