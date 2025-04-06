# dync

repo to sync all my dotfiles across different machines

## Installation

```bash
cd "$HOME/.config"
git clone git@github.com:anton-oz/dync.git
```
move to `~/.config` and clone this repo.
```bash
source "$HOME/.config/dync/src/shcripts/index.sh"
```
then add this line to the end of your shell config file

example:
```bash
# bash
echo source "$HOME/.config/dync/src/shcripts/index.sh" >> $HOME/.bashrc

# zsh
echo source "$HOME/.config/dync/src/shcripts/index.sh" >> $HOME/.zshrc
```
