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
DEV_CONFIG_TARGET="$DYNC/dev/.config"
DEV_HOME_TARGET="$DYNC/dev"

# source colors and functions
. $SRC/colors.sh
. $SRC/functions.sh


if [[ $1 == 'list' ]]; then
	listFiles
	exit 0
fi

if [[ $1 == 'add' ]]; then
	shift
	if [[ $# -eq 0 ]]; then
		printf "\n$ERROR add needs at least one file or directory to add\n\n"
		exit 1
	fi
	addFile $@
	wait
	exit 0
fi

if [[ $1 != "-y" ]]; then
	confirm
fi

cd $DYNC

if [[ $(ls -1a dev | wc -l) -gt 2 ]]; then
	backup
fi

COLOR_DIR="${DIR}$BACKUP${NC}"
copyDotfiles
wait
printf "\n${SUCCESS} dync complete ${NC}\n\n"
