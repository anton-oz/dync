# linux shtuff
alias shutd="shutdown now"
alias slp="systemctl suspend"

alias e='exit'
alias q='exit'

alias gits="cat /home/son/.oh-my-zsh/plugins/git/README.md | rg -iw"

alias n="nvim"
alias nd="nvim ./"
alias nt="nvim +terminal"

alias code="code-insiders"

alias empty-trash="rm -rf ~/.local/share/Trash/*"

# NOTE: tmux

## kill commands
alias tmks="tmux kill-session"
alias tmkst="tmux kill-session -t"
alias tmkw="tmux kill-window"
alias tmkp="tmux kill-pane"

## creation commands
alias tmns="tmux new -s"

## session manipulation commands
alias tmd="tmux detach"
alias tma="tmux a"
alias tmat="tmux a -t"

## pane resizing commands
alias tmrpx="tmux resizep -x"
alias tmrpx="tmux resizep -y"

## window swapping commands
alias tmsw="tmux swapw -t"

## printing / info commands
alias tmls="tmux ls"

## custom sesssions
alias tmsf="tmux source-file"

# zathura
alias zat="zathura"

# yazi
alias y="yazi"

# for viewing images in kitty
alias icat="kitten icat"

# gdb
alias gdb="gdb -q" # so that you dont get the verbose message every startup

# .venv shtuff
alias dac="deactivate"

# llama.cpp
alias llama-server="$HOME/coder/llm/llama.cpp/build/bin/llama-server"

# cargo 
alias carb="cargo build"
alias carc="cargo check"
alias card="cargo doc"
alias carr="cargo run"
alias cart="cargo test"

# homebrew
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
