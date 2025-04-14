#!/bin/bash

confirm() {
	confirm=""
	loop_num=0
	while [[ $confirm != [yY] || $confirm != [yY][eE][sS] ]]; do
		if [[ $loop_num -gt 0 ]]; then
			printf "\nPlease enter Y or n to continue or exit dync\n"
		fi
		printf "\n%s" "Are you sure you want to dync your files? (Y/n): "
		read confirm
		if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
			return 0
		elif [[ $confirm == [nN] || $confirm == [nN][oO] || $confirm == [qQ] ]]; then
			printf "\n"
			exit 0
		fi
		loop_num=$(($loop_num + 1))
	done
}

copyAllToTarget() {
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

backup() {
	cd $DYNC/dev
	# if backup folder doesnt exist, create it
	if [[ ! -d $BACKUP ]]; then
		mkdir $BACKUP
		COLOR_DIR="${DIR}$BACKUP ${NC}"
		printf "\n${IMPORTANT} Created backup directory @ $COLOR_DIR\n"
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
		COLOR_DIR="${DIR}$BACKUP_LOCATION ${NC}"
		printf "\n${IMPORTANT} Backup Success @ $COLOR_DIR\n"
		return 0
	else
		printf "\n$ERROR failed to backup files. aborting.\n\n"
		exit 1
	fi
}

copyDotfiles() {
	cd $DOTFILES
	copyAllToTarget $DEV_HOME_TARGET
}

listFiles() {
	printf "\n${IMPORTANT} Files currently in ${DIR}$DOTFILES ${NC}\n"
	ls -1A --color=auto $DOTFILES
	printf "\n"
}

addFile() {
	printf "\n"
	for arg in $@
	do
		rsync -ar $arg $DOTFILES
		printf "$arg added to $DOTFILES\n"
	done
	printf "\n"
}

watchDotfiles() {
	EVENTS="CREATE,CLOSE_WRITE,DELETE,MODIFY,MOVED_FROM,MOVED_TO"
}



