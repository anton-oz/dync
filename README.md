# dync
repo to sync all my dotfiles across different machines

## Installation

move to `~/.config` and clone this repo.
```bash
cd "$HOME/.config"
git clone git@github.com:anton-oz/dync.git
```
depending on your shell enter this command and dync is installed!
```bash
# bash
echo alias dync="$HOME/.config/dync/src/shcripts/dync.sh" >> $HOME/.bashrc

# zsh
echo alias dync="$HOME/.config/dync/src/shcripts/dync.sh" >> $HOME/.zshrc
```
