cd() {
  builtin cd "$@"

  if [[ -z "$VIRTUAL_ENV" ]] ; then
    ## If env folder is found then activate the vitualenv
      if [[ -d ./.venv ]] ; then
        source ./.venv/bin/activate
      elif [[ -f ./bin/activate ]]; then
        source ./bin/activate
      fi

  else
    ## check the current folder belong to earlier VIRTUAL_ENV folder
    # if yes then do nothing
    # else deactivate
      parentdir="$(dirname "$VIRTUAL_ENV")"
      if [[ "$PWD"/ != "$parentdir"/* ]] ; then
        deactivate
      fi
  fi
}

wcd() {
  if [[ $# -eq 0 ]]; then
    echo "wcd <put binary/file here that you want to cd to>"
    return 0
  fi
  cd $(dirname $(which $1))
}

# if capslock stops responding as hyper key run this to fix
# only works if running X11
runmod() {
  xmodmap -e "remove mod4 = Hyper_L"
  xmodmap -e "add mod3 = Hyper_L"
}

# get size of target githuhb repo
reposize() {
  if [[ -z $1 || -z $2 || $# -gt 2 ]]; then
    printf "Usage: reposize <user> <repo>\n"
    return 1
  fi
  USER_NAME=$1
  REPO_NAME=$2

  REPO_SIZE=$(eval curl -sf "https://api.github.com/repos/$USER_NAME/$REPO_NAME" | jq -r ".size")

  if [[ -z $REPO_SIZE ]]; then
    printf "failed to get repo :(\n"
    return 1
  fi

  printf "size of github.com/$USER_NAME/$REPO_NAME is: $REPO_SIZE KB\n"
}

# removes duplicate entries in PATH
cleanpath() {
  export PATH=$(echo $PATH | awk -v RS=':' -v ORS=":" '!a[$1]++{if (NR > 1) printf ORS; printf $a[$1]}')
}

tarsee() {
  if [[ -z $1 ]]; then
    echo "need an arg"; return 1
  fi
  tar -tzf $1
}

mkdircd() {
  if [[ -z $1 ]]; then 
    echo "need an argument"
    return 1
  fi

  mkdir $1 && cd $1
}

# check for updates
fullupd() {
  if [[ $# -gt 1 ]]; then
    return
  fi

  brew update

  # keep at bottom
  sudo apt update
  echo "checked"
}

# upgrade system
fullupg() {
  if [[ $# -gt 1 ]]; then
    return 1
  fi

  brew upgrade
  omz update


  sudo apt update
  echo "updated"
}

postgres() {
  psql -U postgres -h localhost -W
}

zsh-custom() {
  cd $ZSH_CUSTOM
  nvim ./
  cd -
}

grubreload() {
  sudo update-grub
}

grubedit() {
  sudoedit /etc/default/grub && grubreload
}

changedns() {
  sudoedit /etc/systemd/resolved.conf
}

startModel() {
  # vllm .venv location
  cd /home/son/coder/llm/vLLM/
  # put what ever you want to be default model here
  vllm serve "Qwen/Qwen2.5-Coder-7B-Instruct" --enable-auto-tool-choice --tool-call-parser hermes --dtype="bfloat16" --quantization="bitsandbytes" --gpu-memory-utilization=0.82 --disable-log-requests --disable-log-stats
  # on server shutdown return to whereever you were in filesystem
  cd -
}

todo() {
  n ~/coder/notes/todo.md
}

loc () {
  # gets lines of code in target dir
  if [[ $# -eq 0 ]] || [[ $# -gt 1 ]]; then
    return 1
  fi

  find $1 -type f | xargs wc -l
}

sys() {
  tmux source-file ~/.tmux/windows/sys
}

grub-toggle-os-prober() {
  local help_message="grub-toggle-os-prober [ --on, on ] | [ --off, off ]"
  if [[ $# -eq 0 ]] || [[ $# -gt 1 ]]; then
    echo $help_message
    return 0
  fi

  case $1 in
    --off|off)
      sudo sed -i 's/GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=true/g' /etc/default/grub
      sudo update-grub
      return 0
      ;;
    --on|on)
      sudo sed -i 's/GRUB_DISABLE_OS_PROBER=true/GRUB_DISABLE_OS_PROBER=false/g' /etc/default/grub
      sudo update-grub
      return 0
      ;;
    *)
      echo unknown option: $1
      echo usage:
      echo "  $help_message"
      return 1
  esac
}

reboot-to-windows () {
  grub-toggle-os-prober on

  windows_name=$(sudo grep -i windows /boot/grub/grub.cfg -m 1 | cut -d"'" -f2)

  sudo grub-reboot $windows_name
  sudo reboot
}

reboot-to-ubuntu() {
  grub-toggle-os-prober off

  ubuntu_name=$(sudo grep -i ubuntu /boot/grub/grub.cfg -m 1 | cut -d"'" -f2)

  sudo grub-reboot $ubuntu_name
  sudo reboot
}

penpot() {
  local help_message
  help_message="penpot <start | stop>"

  if [[ $# -eq 0 ]] || [[ $# -gt 1 ]]; then
    echo $help_message
    return 0
  fi

  local parent
  parent="$HOME/coder/apps/penpot/"

  case $1 in
    start)
      docker compose -p penpot -f $parent/docker-compose.yaml up -d
      return 0
      ;;
    stop)
      docker compose -p penpot -f $parent/docker-compose.yaml down
      return 0
      ;;
    *)
      echo "unkown option $1"
      echo usage: $help_message
      return 1
      ;;
  esac
}

gitlab() {
  ssh \
    -L 8080:localhost:8080 \
    -L 8443:localhost:8443 \
    -L 6022:localhost:6022 thor@asgard
}
