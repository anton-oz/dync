#!/bin/bash

showHelp() {
	printf "Usage: dync [flags] [command]\n"
	printf "  flags:\n"
	printf "    -h,--help	 show this help message\n"
	printf "    -V,--version show dync version\n"
	printf "    -v		 verbose output\n"
	printf "    -s		 silence all output (does not silence errors)\n"
	printf "  commands:\n"
	printf "    add		 add a file to dync\n"
	printf "    rm, remove	 remove a file from dync\n"
	printf "    boot	 bootstrap your dync files\n"
	printf "    list	 list files currently in dync\n"
	printf "    restore	 restore to a backup number\n"
	printf "    status	 show git status for dync directory\n"
	printf "    sync	 sync the links you have added with tracked files\n"
	exit 0
}

showVersion() {
	printf "dync v0.1.0\n"
	exit 0
}

##
# Takes a reference directory, and copies everything from that directory
# to the target directory.
##
copyAllToTarget() {
	if [[ -z $1 ]]; then
		printf "$ERROR${IMPORTANT} must give a target ${NC}\n"
		exit 1
	elif [[ ! -d $1 ]]; then
		printf "$ERROR${IMPORTANT} target must be a directory ${NC}\n"
		printf "\ttarget = ${1}\n"
		exit 1
	fi

	ref_dir="$LINKS"
	target_dir="$1"

	for file in "$ref_dir"/* "$ref_dir"/.*; do
		##
		# For every file in the reference directory, if it is not `.` or `..`
		# sync to target directory.
		filename=$(basename "$file")
		echo $filename
		[[ "$filename" == "." || "$filename" == ".." ]] && continue
		rsync $RSYNCFLAGS -L "$filename" "$target_dir/"
	done

	##
	# If any problems with syncing, exit the program.
	wait
	if [[ $? -eq 0 ]]; then
		return 0
	else
		exit 1
	fi
}

backup() {
	if [[ -z $( isDotfilesEmpty ) ]]; then
		echo no files in dync, aborting backup...
		return 0
	fi

	cd $DYNC

	# ##
	# If backup folder doesnt exist, create it
	if [[ ! -d $BACKUPS ]]; then
		echo "Root permissions only needed once to create backup dir"
		echo "and give dync permission to write to it"
		echo "If you want to verify, this message exists at $DYNC/src/functions.sh:73"
		sudo mkdir -p $BACKUPS
		sudo chown -R "$USER" $BACKUPS
		BACKUP_DIR="${DIR}$BACKUPS ${NC}"
		if [[ $SILENT = false ]]; then
			printf "${IMPORTANT} Created backup directory @ $BACKUP_DIR\n"
		fi
	fi

	##
	# Get the number of backups, and the directory that contains the backups.
	BACKUP_NUM=$(($(ls -A $BACKUPS | wc -l)))
	BACKUP_LOCATION=$(realpath "${BACKUPS}/${BACKUP_NUM}")

	##
	# Create the directory for the backup you are about to make.
	mkdir -p $BACKUP_LOCATION

	# TODO:
	# I want to change to $HOME instead, but only backup the files that are going
	# to be affected by dync
	cd $DOTFILES
	copyAllToTarget $BACKUP_LOCATION
	zipBackup $BACKUP_LOCATION

	if [[ $? -eq 0 ]]; then
		BACKUP_DIR="${DIR}$BACKUP_LOCATION ${NC}"
		BACKUP_SUCCESS_MESSAGE=$(printf "${IMPORTANT} \$HOME backup @ $BACKUP_DIR\n")
		return 0
	else
		printf "$ERROR${IMPORTANT} failed to backup files. aborting. ${NC}\n"
		exit 1
	fi
}

zipBackup() {
	if [[ -z $1 ]]; then
		printf "$ERROR zipBackup: need one argument\n"
		exit 1
	fi
	if [[ ! -d $1 ]]; then
		printf "$ERROR zipBackup: argument must be a directory\n"
		exit 1
	fi
	# supresses tar messages to stdout
	tar -czf "$1.tar.gz" $1 2> /dev/null && rm -rf $1
}

restoreToBackup() {
	# TODO:
	# - get a arg for which backup to choose
	# - unzip and rsync to home_target
	shift
	local backup
	if [[ -z $1 ]] || [[ $# -gt 1 ]]; then
		printf "$ERROR restoreToBackup: need a backup number to restore to\n"
		exit 1
	fi

	tar -xzf "$BACKUPS/$1.tar.gz" --strip-components=5 -C "$HOME_TARGET"
	exit 0
}

copyDotfiles() {
	cd $DOTFILES
	copyAllToTarget $HOME_TARGET
}

isDotfilesEmpty() {
	ls -A $DOTFILES/.config && ls -A $DOTFILES -I .config
}

listFiles() {
	shift

	if [[ -z "$( isDotfilesEmpty )" ]]; then
		printf "${IMPORTANT} No files currently tracked by dync ${NC}\n"
		exit 0
	fi

	printf "${IMPORTANT} Files currently tracked by dync: ${NC}\n"
	printf "${DIR}.config${NC}"
	find $DOTFILES/.config -maxdepth 2 -type d -printf "  ${DIR}%P${NC}\n"
	find $DOTFILES -maxdepth 2 -type f -printf "%P\n"
	exit 0
}

addFile() {
	shift

	if [[ $# -eq 0 ]]; then
		printf "$ERROR${IMPORTANT} add needs at least one file or directory to add ${NC}\n"
		exit 1
	fi

	if [[ ! -d $DOTFILES ]]; then
		mkdir -p $DYNC/dotfiles
	fi

	if [[ ! -d $LINKS ]]; then
		mkdir -p $DYNC/links
	fi

	if [[ ! -d "$DOTFILES/.config" ]]; then
		mkdir -p "$DOTFILES/.config"
	fi
	if [[ ! -d "$LINKS/.config" ]]; then
		mkdir -p "$LINKS/.config"
	fi

	for file in $@; do
		##
		# If file comes from ~/.config dir add to .config dir in $DYNC/links
		##
		if [[ "$(basename $(dirname $(realpath $file)))" == ".config" ]]; then
			if [[ $v_set == true ]]; then
				ln -v -s $(realpath $file) $(realpath "$LINKS/.config/$(basename $file)")
			else
				ln -s $(realpath $file) $(realpath "$LINKS/.config/$(basename $file)")
			fi
		continue
		fi

		if [[ $v_set == true ]]; then
			ln -v -s $(realpath $file) $(realpath $LINKS)
		else
			ln -s $(realpath $file) $(realpath $LINKS)
		fi

	done

	exit 0
}

removeFile() {
	shift
	for arg in $@; do
		if [[ $(find "$DYNC/links/$arg") ]]; then
			rm -rf $DYNC/links/$arg
		fi
		if [[ $(find "$DYNC/dotfiles/$arg") ]]; then
			rm -rf $DYNC/dotfiles/$arg
		fi
		shift
	done
	
}

##
# copys files from ./links to ./dotfiles
##
syncFiles() {
	if [[ $# -gt 1 ]]; then
		printf "$ERROR${IMPORTANT} sync takes no arguments ${NC}\n"
		exit 1
	fi

	# TODO: combine into one command
	rsync $RSYNCFLAGS -L $LINKS/.* $DOTFILES
	# BUG: if no unhidden files, this will throw
	# an error
	if [[ $(ls $LINKS | wc -w) -gt 0 ]]; then
		rsync $RSYNCFLAGS -L $LINKS/* $DOTFILES
	fi

	printf "${SUCCESS}  dynced  ${NC}\n"
	exit 0
}

##
#
##
showStatus() {
	cd $DYNC
	git status
	cd - >/dev/null
	exit 0
}

bootstrap() {
	if [[ -z $( isDotfilesEmpty ) ]]; then
		echo no files in dync, aborting bootstrap...
		return 0
	fi

	cd $DYNC

	BACKUP_SUCCESS_MESSAGE=""

	if [[ $(ls -1A $HOME_TARGET | wc -l) ]]; then
		backup
	fi

	copyDotfiles

	if $SILENT; then
		exit 0
	fi
	printf "${BACKUP_SUCCESS_MESSAGE}\n"
	printf "${SUCCESS}  dynced  ${NC}\n"
	exit 0
}
