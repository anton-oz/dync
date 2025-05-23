#!/bin/bash

showHelp() {
	printf "Usage: dync [flags] [command]\n"
	printf "  options:\n"
	printf "    -h,--help	show this help message\n"
	printf "    -y		skip confirm prompt\n"
	printf "    -v		verbose output\n"
	printf "    -s		silence all output (does not silence errors)\n"
	printf "  commands:\n"
	printf "    add		add a file to dync\n"
	printf "    list	list files currently in dync\n"
	exit 0
}

# idk if I want this anymore
confirmPrompt() {
	local confirm=""
	loop_num=0
	while [[  $confirm != [yY] || $confirm != [yY][eE][sS] ]]; do
		if [[ "$loop_num" == 2 ]]; then
			exit 1
		fi
		if [[ $loop_num -gt 0 ]]; then
			printf "\n${IMPORTANT} Please enter Y or n to continue or exit dync ${NC}\n"
			printf "${IMPORTANT} To skip this confirmation use dync -y ${NC}\n"
		fi
		printf "${IMPORTANT}%s${NC} " " dync your files? (Y/n): "
		read confirm
		if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
			return 0
		elif [[ $confirm == [nN] || $confirm == [nN][oO] || $confirm == [qQ] ]]; then
			exit 0
		fi
		loop_num=$(($loop_num + 1))
	done
}

# used for dyncing
copyAllToTarget() {
	if [[ -z $1 ]]; then
		printf "$ERROR${IMPORTANT} must give a target ${NC}\n"
		exit 1
	elif [[ ! -d $1 ]]; then
		printf "$ERROR${IMPORTANT} target must be a directory ${NC}\n"
		printf "\ttarget = ${1}\n"
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
	if [[ ! -d $BACKUPS ]]; then
		mkdir $BACKUPS
		COLOR_DIR="${DIR}$BACKUPS ${NC}"
		if [[ $SILENT = false ]]; then
			printf "${IMPORTANT} Created backup directory @ $COLOR_DIR\n"
		fi
	fi

	BACKUP_NUM=$(($(ls -A $BACKUPS | wc -l)))
	# date string format
	#							24 hour time : seconds__month_date_year
	BACKUP_DATETIME=$(date +"%R:%S__%m_%d_%y")
	# backup name and location
	BACKUP_NAME="${BACKUP_NUM}_${BACKUP_DATETIME}"
	BACKUP_LOCATION="${BACKUPS}/${BACKUP_NAME}"

	mkdir $BACKUP_LOCATION
	copyAllToTarget $BACKUP_LOCATION
	zipBackup $BACKUP_LOCATION
	if [[ $? -eq 0 ]]; then
		COLOR_DIR="${DIR}$BACKUP_LOCATION ${NC}"
		BACKUP_SUCCESS_MESSAGE=$(printf "${IMPORTANT} \$HOME backup @ $COLOR_DIR\n")
		return 0
	else
		printf "$ERROR${IMPORTANT} failed to backup files. aborting. ${NC}\n"
		exit 1
	fi
}

zipBackup() {
	if [[ -z $1 ]]; then
		printf "$ERROR zipBackup: need at one argument\n"
		exit 1
	fi
	if [[ ! -d $1 ]]; then
		printf "$ERROR zipBackup: argument must be a directory\n"
		exit 1
	fi
	# supresses tar messages to stdout
	tar -czf "$1.tar.gz" $1 2> /dev/null && rm -rf $1
}

# restoreToBackup() {
# 	if [[ -]]
# }

copyDotfiles() {
	cd $DOTFILES
	copyAllToTarget $DEV_HOME_TARGET
}

listFiles() {
	shift
	list="ls -A1 --color=auto $DOTFILES"
	if [[ $# -gt 0 ]]; then
		while getopts ":r" opt; do
			case $opt in
				r) list+=" -R"; ;;
				\?) printf "$ERROR unknown list option: $OPTARG\n"; exit 1 ;;
			esac
		done
	fi
	printf "${IMPORTANT} Files currently tracked by dync: ${NC}\n"
	$list
	exit 0
}

addFile() {
	shift
	if [[ $# -eq 0 ]]; then
		printf "$ERROR${IMPORTANT} add needs at least one file or directory to add ${NC}\n"
		exit 1
	fi
	for file in $@
	do
		rsync $RSYNCFLAGS $file $DOTFILES
		printf "$file added to $DOTFILES\n"
	done
	exit 0
}

watchDotfiles() {
	EVENTS="CREATE,CLOSE_WRITE,DELETE,MODIFY,MOVED_FROM,MOVED_TO"
}



