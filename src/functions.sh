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
	printf "    sync	 update dotfiles to latest changes\n"
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
		printf "${ERROR}${IMPORTANT} must give a target ${NC}\n"
		exit 1
	elif [[ ! -d $1 ]]; then
		printf "${ERROR}${IMPORTANT} target must be a directory ${NC}\n"
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
		[[ "$filename" == "." || "$filename" == ".." ]] && continue
		rsync "$RSYNCFLAGS" -L "$filename" "$target_dir/"
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

##
# echos absolute file paths that match between tracked files and
# files in $HOME directory
getMatchingFiles() {
	local home_files tracked_files matching_files

	home_files=$(find "$HOME_TARGET" \
		-maxdepth 1 \
		-not -path "$CONFIG_TARGET" \
		-printf "%P\n" | sort)
	tracked_files=$(ls --ignore=".config" -A "$DOTFILES" | sort)
	
	matching_files=$(comm -12 \
		<(echo "$tracked_files") \
		<(echo "$home_files") | \
		sed "s|^|$HOME_TARGET\/|"
	)

	local config_files tracked_config_files matching_config_files

	config_files=$(find "$CONFIG_TARGET" -maxdepth 1 -printf "%P\n" | sort)
	tracked_config_files=$(ls -A "$DOTFILES" | sort)
	
	matching_config_files=$(comm -12 \
		<(echo "$tracked_config_files") \
		<(echo "$config_files") | \
		sed "s|^|${HOME_TARGET}/|"
	)

	echo $matching_files
	echo $matching_config_files
}

##
# reworked copy function
##
copyMatchingFilesToTarget() {
	if [[ -z $1 ]] || [[ ! -d $1 ]]; then
		printf "%s %s\n" \
			"${ERROR}${IMPORTANT}" \
			"copyMatchesToTarget: arg not a directory ${NC}\n"
		return 1
	fi

	cp "$(getMatchingFiles)" $1
}

##
# backup only backs up files that would be updated by dync.
# Instead of backing up entire $HOME dir ( which could take a while ), only
# backup matching files.
##
backup() {
	# this will compare files between dotfiles and home to something a match
	# But, it will match .config

	if [[ -z $( isDotfilesEmpty ) ]]; then
		 printf "${IMPORTANT}no files in dync, aborting backup...${NC}\n"
		 return 0
	fi

	if [[ ! -d $BACKUPS ]]; then
		printf "%s\n%s\n%s\n" \
			"Root permissions only needed once to create backup directory"
			"and give dync permission to write to that directory."
			"line: ${LINENO}, function: ${FUNCNAME[0]}"
		sudo mkdir -p "$BACKUPS"
		sudo chown -R "$USER" "$BACKUPS"
		BACKUP_DIR="${DIR}$BACKUPS ${NC}"
		if [[ $SILENT = false ]]; then
			 printf "${IMPORTANT} Created backup directory @ $BACKUP_DIR\n"
		fi
	fi
	
	BACKUP_NUM=$(ls -A "$BACKUPS" 2>/dev/null | wc -l)
	BACKUP_LOCATION=$(realpath "${BACKUPS}/${BACKUP_NUM}")

	mkdir -p "$BACKUP_LOCATION"

	copyMatchingFilesToTarget "$BACKUP_LOCATION" </dev/null
	zipBackup "$BACKUP_LOCATION"

	if [[ $? -eq 0 ]]; then
		BACKUP_DIR="${DIR}$BACKUP_LOCATION ${NC}"
		BACKUP_SUCCESS_MESSAGE=$(printf "${IMPORTANT} \$HOME backup @ $BACKUP_DIR\n")
		return 0
	else
		printf "${ERROR}${IMPORTANT} failed to backup files. aborting. ${NC}\n"
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
	if [[ $1 == "backups" ]] || [[ $1 == '-b' ]]; then
		printf "${IMPORTANT} Backups available to restore to: ${NC}\n"
		ls -lAh $BACKUPS | \
			awk 'NR > 1 {$1=$2=$3=$4=$5=""; print $0}' | \
			sed 's/^[[:space:]]*//'
		exit 0
	fi

	if [[ -z "$(isDotfilesEmpty)" ]]; then
		printf "${IMPORTANT} No files currently tracked by dync ${NC}\n"
		return 0
	fi

	# Needs a refactor, this is fucked
	printf "${IMPORTANT} Files currently tracked by dync: ${NC}\n"
	printf "${DIR}.config${NC}"
	find $DOTFILES/.config \
		-maxdepth 1 \
		-type d \
		-printf "  ${DIR}%P${NC}\n"
	find $DOTFILES \
		-maxdepth 1 \
		-not -path $DOTFILES/.config* \
		-type d \
		-printf "${DIR}%P${NC}\n"
	find $DOTFILES -maxdepth 1 -type f -printf "%P\n"
	return 0
}

addFile() {
	shift

	if [[ $# -eq 0 ]]; then
		printf "%s %s %s\n" \
			"${ERROR}${IMPORTANT}" \
			"add needs at least one file or directory to add" \
			"${NC}"
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
				ln -v -s \
					$(realpath $file) \
					$(realpath "$LINKS/.config/$(basename $file)")
			else
				ln -s \
					$(realpath $file) \
					$(realpath "$LINKS/.config/$(basename $file)")
			fi
		continue
		fi

		if [[ $v_set == true ]]; then
			ln -v -s $(realpath $file) $(realpath $LINKS)
		else
			ln -s $(realpath $file) $(realpath $LINKS)
		fi

	done

	syncFiles

	exit 0
}

removeFile() {
	shift
	for arg in $@; do
		if [[ -f "$DYNC/links/$arg" ]]; then
			rm -rf $DYNC/links/$arg
		elif [[ -f "$DYNC/dotfiles/$arg" ]]; then
			rm -rf $DYNC/dotfiles/$arg
		else
			echo $arg is not tracked by dync
		fi
		shift
	done
	
}

##
# copies files from ./links to ./dotfiles
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
		printf "${IMPORTANT}no files in dync, aborting bootstrap...${NC}\n"
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
