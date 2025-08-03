# dync

sync dotfiles across machines

> **Note:** dync is only compatible with unix based systems

## Quick Install

**ZSH**
```bash
cd "$HOME/.config"
git clone git@github.com:anton-oz/dync.git
cd dync
echo "export DYNC=$(realpath ./)" >> ~/.zshrc
sed -i '$d' .gitignore
sudo ln -s $(realpath $DYNC/src/dync.sh) /usr/bin/dync
```

## Installation

1. Move to `~/.config`, or wherever you would like dync to live and clone this repo.
```bash
cd "$HOME/.config"
git clone git@github.com:anton-oz/dync.git
cd dync
```
2. **IMPORANT: Make sure that you are in the dync directory before running this next command.**
```bash
# zsh
echo "export DYNC=$(realpath ./)" >> ~/.zshrc
# bash
echo "export DYNC=$(realpath ./)" >> ~/.bashrc
# you will need to restart your shell so these changes take effect
```
3. remove `./dotfiles` from `.gitignore`.
```bash
# remove the tail end of .gitignore to add your files to git
sed -i '$d' .gitignore
```
4. link dync to bin and dync is good to go!
```bash
# Linux, Mac OS
sudo ln -s $(realpath $DYNC/src/dync.sh) /usr/bin/dync
```

## Usage

To check if installed correctly, enter this command:
```sh
dync
```
You should see the help menu, with basic commands and what they do.

#### Notes

Dync will only backup and restore files that exist inside of `./dotfiles`. If you
restore to a previous backup, dync will not remove files that dont exist in that
backup. This is to prevent deletion of things that were not meant to be deleted in
the `$HOME` directory and keep the files that dync tracks and backs up to a minimum.
