#!/usr/bin/env bash

if [[ ! "$HOME" ]]; then
	printf "no HOME varible set up\n"
	return 1
fi

DOTSYNC_SRC="$HOME/.config/dync/src"

DOTFILES="$DOTSYNC_SRC/dotfiles"
BACKUP="$DOTSYNC_SRC/backup"

# CONFIG_TARGET="$HOME/.config/"
# HOME_TARGET="$HOME"
DEV_CONFIG_TARGET="$DOTSYNC_SRC/dev/.config"
DEV_HOME_TARGET="$DOTSYNC_SRC/dev"

. $DOTSYNC_SRC/shcripts/colors.sh

function backup() {
	cd $DOTSYNC_SRC/dev
	cp * $BACKUP
	if [[ $? -gt 0 ]]; then
		return 1
	fi
	cp -r .config $BACKUP
	if [[ $? -eq 0 ]]; then
		return 0
	else
		return 1
	fi
}

function copyToConfig() {
	cd $DOTFILES
	rsync -a * $DEV_HOME_TARGET
}

cd $DOTSYNC_SRC

if [[ $(ls -1a dev | wc -l) -gt 2 ]]; then
	backup
fi

if [[ $? -eq 0 ]]; then
	COLOR_DIR="${DIR}$BACKUP${NC}"
	printf "Backup success.\nBackup location: $COLOR_DIR\n"
	copyToConfig
	wait 
	printf "files copied\n"
else
	printf "\n$ERROR failed to backup files. aborting.\n\n"
fi

