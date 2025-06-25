# dync

repo to sync all my dotfiles across different machines

## Installation

move to `~/.config`, or wherever you would like dync to live and clone this repo.
```bash
cd "$HOME/.config"
git clone git@github.com:anton-oz/dync.git
```

depending on your shell enter this command and dync is installed!

```bash
# Linux
sudo ln -s $(realpath <dync-location>) /usr/bin
```

### Notes

Dync will only backup and restore files that exist inside of `./dotfiles`. If you
restore to a previous backup, dync will not remove files that dont exist in that
backup. This is to prevent deletion of things that were not meant to be deleted in
the `$HOME` directory and keep the files that dync tracks and backs up to a minimum.
