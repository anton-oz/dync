#!/bin/bash

confirm() {
	confirm=""
	loop_num=0
	while [[  $confirm != [yY] || $confirm != [yY][eE][sS] ]]; do
		if [[ "$loop_num" == 2 ]]; then
			printf "\n${IMPORTANT} To skip this confirmation use dync -y ${NC}\n\n"
			exit 0
		fi
		if [[ $loop_num -gt 0 ]]; then
			printf "\n${IMPORTANT} Please enter Y or n to continue or exit dync ${NC}\n"
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

# used for dyncing
copyAllToTarget() {
	if [[ -z $1 ]]; then
		printf "\n$ERROR\n${IMPORTANT} must give a target ${NC}\n\n"
		exit 1
	elif [[ ! -d $1 ]]; then
		printf "\n$ERROR\n${IMPORTANT} target must be a directory ${NC}\n\n"
		printf "\ttarget = ${1}\n\n"
		exit 1
	fi
	rsync $RSYNCFLAGS * .* $1
	wait
	if [[ $? -eq 0 ]]; then
		return 0
	else
		exit 1
	fi
}

backup() {
	# NOTE: will be changing to $HOME at some point
	cd $DYNC/test_home

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
		printf "\n$ERROR\n${IMPORTANT} failed to backup files. aborting. ${NC}\n\n"
		exit 1
	fi
}

copyDotfiles() {
	cd $DOTFILES
	copyAllToTarget $DEV_HOME_TARGET
}

listFiles() {
	printf "\n${IMPORTANT} Files currently in \n ${DIR}$DOTFILES ${NC}\n\n"
	ls -A1 --color=auto $DOTFILES
	printf "\n"
	exit 0
}

addFile() {
	shift
	if [[ $# -eq 0 ]]; then
		printf "\n$ERROR\n${IMPORTANT} add needs at least one file or directory to add ${NC}\n\n"
		exit 1
	fi
	printf "\n"
	for arg in $@
	do
		rsync $RSYNCFLAGS $arg $DOTFILES
		printf "$arg added to $DOTFILES\n"
	done
	printf "\n"
	exit 0
}

watchDotfiles() {
	EVENTS="CREATE,CLOSE_WRITE,DELETE,MODIFY,MOVED_FROM,MOVED_TO"
}



