#!/usr/bin/env bash

if [[ ! "$HOME" ]]; then
	printf "\nno HOME varible set up, aborting\n\n"
	exit 1
fi

DOTSYNC_SRC="$HOME/.config/dync/src"

DOTFILES="$DOTSYNC_SRC/dotfiles"
BACKUP="$DOTSYNC_SRC/backup"
SHCRIPTS="$DOTSYNC_SRC/shcripts"

# CONFIG_TARGET="$HOME/.config/"
# HOME_TARGET="$HOME"
DEV_CONFIG_TARGET="$DOTSYNC_SRC/dev/.config"
DEV_HOME_TARGET="$DOTSYNC_SRC/dev"

# source colors and functions
. $SHCRIPTS/colors.sh
. $SHCRIPTS/functions.sh

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

cd $DOTSYNC_SRC

if [[ $(ls -1a dev | wc -l) -gt 2 ]]; then
	backup
fi

COLOR_DIR="${DIR}$BACKUP${NC}"
copyDotfiles
wait
printf "\n${SUCCESS} dync complete ${NC}\n\n"
