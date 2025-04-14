#!/bin/bash -e

if [[ ! "$HOME" ]]; then
	printf "\nno HOME varible set up, aborting\n\n"
	exit 1
fi

# DYNC="$HOME/.config/dync/src"
DYNC="$HOME/.config/dync"

DOTFILES="$DYNC/dotfiles"
BACKUP="$DYNC/backup"
SRC="$DYNC/src"

# CONFIG_TARGET="$HOME/.config/"
# HOME_TARGET="$HOME"
DEV_CONFIG_TARGET="$DYNC/test_home/.config"
DEV_HOME_TARGET="$DYNC/test_home"

RSYNCFLAGS="-var"

# source colors and functions
. $SRC/colors.sh
. $SRC/functions.sh


if [[ $1 == 'list' ]]; then
	listFiles
fi

if [[ $1 == 'add' ]]; then
	addFile $@
fi

if [[ $1 != "-y" ]]; then
	confirm
fi

cd $DYNC

if [[ $(ls -1a test_home | wc -l) -gt 2 ]]; then
	backup
fi

copyDotfiles
wait
printf "\n${SUCCESS}  dynced  ${NC}\n\n"
