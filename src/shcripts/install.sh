#!/usr/bin/env bash

if [[ ! "$HOME" ]]; then
	echo "no HOME varible set up"
	return 1
fi

DOTSYNC_SRC="$HOME/.config/dotSync/src"
DOTSYNC_DOTFILES="$DOTSYNC_SRC/dotfiles"

configDotfiles="$DOTSYNC_DOTFILES/.config/"
HOMEDotfiles="$DOTSYNC_SRC/.config"

# CONFIG_TARGET="$HOME/.config/"
# HOME_TARGET="$HOME"
DEV_CONFIG_TARGET="$DOTSYNC_SRC/dev/.config"
DEV_HOME_TARGET="$DOTSYNC_SRC/dev/"

. $DOTSYNC_SRC/shcripts/colors.sh

# function backup() {
#
# }

function removeDevFiles() {
	cd "$DOTSYNC_SRC/dev/"
	rm -rf *
}

function copyToConfig() {
	cd "$DOTSYNC_DOTFILES/.config/"
	cp * $DEV_CONFIG_TARGET
	echo "copied $ESC$DOTSYNC_DOTFILES/.config to $DEV_CONFIG_TARGET"
}

copyToConfig
