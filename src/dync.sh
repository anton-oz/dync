#!/bin/bash -e

if [[ -z "$HOME" ]]; then
	printf "\nno HOME varible set up, aborting\n"
	exit 1
fi

SYS_NAME=$(uname -s)


# ugly but gets the absolute path of wherever dync is located
DYNC=$(realpath $(dirname $(dirname $BASH_SOURCE[0])))

DOTFILES="$DYNC/dotfiles"
SRC="$DYNC/src"

if [[ "$SYS_NAME" == "Linux" ]]; then
	BACKUPS="/var/local/dync/backups"
elif [[ "$SYS_NAME" == "Darwin" ]]; then
	BACKUPS="/Users/Shared/dync/backups"
else
	echo "Your system is not compatible with dync"
	exit 1
fi

CONFIG_TARGET="$HOME/.config/"
HOME_TARGET="$HOME"
# DEV_CONFIG_TARGET="$DYNC/test_home/.config"
# DEV_HOME_TARGET="$DYNC/test_home"

# source colors and functions
. $SRC/colors.sh
. $SRC/functions.sh

# NOTE:
# default values for flag opts
RSYNCFLAGS="-qar"
CONFIRM=true
SILENT=false

# variables for setting rsync flags
s_set=false
v_set=false

# NOTE:
# if any args process them here
if [[ $# -gt 0 ]]; then
	case $1 in
		-h|--help) showHelp ;;
		-V|--version) showVersion ;;
		# NOTE: commands here
		add) addFile $@ ;;
		list) listFiles $@ ;;
		restore) restoreToBackup $@ ;;
		status) cd $DYNC && git status && cd - && exit 0 ;;
		# NOTE: flags here
		-*) 
			while getopts ":yvs" opt; do
				case $opt in
					y) CONFIRM=false ;;
					v) 
						if $s_set; then
							printf "$ERROR cannot set -s and -v at the same time\n"; exit 1
						fi
						v_set=true
						RSYNCFLAGS="-var" ;;
					s) 
						if $v_set; then
							printf "$ERROR cannot set -s and -v at the same time\n"; exit 1
						fi
						s_set=true
						SILENT=true ;;
					\?) printf "unknown option: $1 \nuse dync --help to display options\n"; exit 1 ;;
				esac
			done 
			;;
		*) printf "Unknown command: $1\nuse dync --help to display options\n"; exit 1;
	esac
fi

# NOTE:
# process flags if neccesary
if $CONFIRM; then
	confirmPrompt
fi

cd $DYNC

BACKUP_SUCCESS_MESSAGE=""
if [[ $(ls -1a test_home | wc -l) -gt 2 ]]; then
	backup
fi

copyDotfiles

if $SILENT; then
	exit 0
fi
printf "${BACKUP_SUCCESS_MESSAGE}\n"
printf "${SUCCESS}  dynced  ${NC}\n"

