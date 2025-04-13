#!/usr/bin/env bash

if [[ ! "$HOME" ]]; then
	printf "\nno HOME varible set up\n"
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

function copyAllToTarget() {
	if [[ -z $1 ]]; then
		printf "\n$ERROR must give a target\n"
		exit 1
	elif [[ ! -d $1 ]]; then
		printf "\n$ERROR target must be a directory\n"
		exit 1
	fi
	rsync -qar * .* $1
	if [[ $? -eq 0 ]]; then
		return 0
	else
		exit 1
	fi
}

function backup() {
	cd $DOTSYNC_SRC/dev
	# if backup folder doesnt exist, create it
	if [[ ! -d $BACKUP ]]; then
		mkdir $BACKUP
		COLOR_DIR="${DIR}$BACKUP${NC}"
		printf "\nCreated backup directory @ $COLOR_DIR\n"
	fi

	# get number of files in $BACKUP - 2 to not count .. .
	BACKUP_NUM=$(($(ls -a $BACKUP | wc -l) - 2))
	# date string format
	#							24 hour time : seconds__month_date_year
	BACKUP_DATETIME=$(date +"%R:%S__%m_%d_%y")
	# backup name and location
	BACKUP_NAME="${BACKUP_NUM}_${BACKUP_DATETIME}"
	BACKUP_LOCATION="${BACKUP}/${BACKUP_NAME}"

	mkdir $BACKUP_LOCATION
	copyAllToTarget $BACKUP_LOCATION
	if [[ $? -eq 0 ]]; then
		COLOR_DIR="${DIR}$BACKUP_LOCATION${NC}"
		printf "\nBackup Success. Location @ $COLOR_DIR\n"
		return 0
	else
		return 1
	fi
}

function copyToConfig() {
	cd $DOTFILES
	copyAllToTarget $DEV_HOME_TARGET
}

cd $DOTSYNC_SRC

if [[ $(ls -1a dev | wc -l) -gt 2 ]]; then
	backup
fi

if [[ $? -eq 0 ]]; then
	COLOR_DIR="${DIR}$BACKUP${NC}"
	copyToConfig
	wait 
	printf "\ndync complete \n\n"
else
	printf "\n$ERROR failed to backup files. aborting.\n\n"
fi

