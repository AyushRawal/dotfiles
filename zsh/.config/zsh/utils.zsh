typeset ZSH_PLUGIN_PATH=${ZSH_PLUGIN_PATH:-${ZDOTDIR}/plugins}
typeset -a YPLUGNIS
# why 'y' ? coz 'z' wasn't free

_yplug() {
  local zmodule=${1:t} zurl=${1} zscript=${2}
  local zpath=${ZSH_PLUGIN_PATH}/${zmodule}
  YPLUGNIS+=("${zpath}")

  if [[ ! -d ${zpath} ]]; then
    mkdir -p ${zpath}
    echo -ne "\e[1;32m${zmodule}: \e[0m"
    git clone --single-branch --recursive --depth 1 https://github.com/${zurl}.git ${zpath}
  fi

  local zscripts=(${zpath}/(init.zsh|${zmodule:t}.(zsh|plugin.zsh|zsh-theme|sh))(NOL[1]))
  if    [[ -f ${zpath}/${zscript} ]]; then source ${zpath}/${zscript}
  elif  [[ -f ${zscripts} ]]; then source ${zscripts}
  else  echo -e "\e[1;31mNo scripts was found for:\e[0m \e[3m${zurl}\e[0m"
  fi
}

yupdate() {
  for p in $(ls -d ${ZSH_PLUGIN_PATH}/*/.git); do
    echo -ne "\e[1;32m${${p%/*}:t}: \e[0m"
    echo -e "\r\033[0K$(git -C ${p%/*} pull --depth=1 --rebase)"
    echo -e "\r\033[0K$(git -C ${p%/*} submodule update --depth=1 --rebase)"
  done
}

_yfplug() {
  local zscript=$ZSH_PLUGIN_PATH/${1:t}
  YPLUGNIS+=("${zscript}")
  if [[ -f $zscript ]]; then source $zscript
  else curl -fsSL $1 -o $zscript && source $zscript
  fi
}

yclean() {
  for p in $(comm -23 <(ls -1d ${ZSH_PLUGIN_PATH}/* | sort) <(printf '%s\n' $YPLUGNIS | sort)); do
    echo -e "\e[1;33mCleaning:\e[0m \e[3m${p}\e[0m"
    rm -rI $p
  done
}

_is_cmd() {
  command -v $1 &> /dev/null
}

ycmp() {
  _is_cmd gh && gh completion -s zsh > $ZDOTDIR/completions/_gh
  _is_cmd pip && pip completion --zsh | sed '/# .*/d;/^\s*$/d' > $ZDOTDIR/completions/_pip
  _is_cmd fnm && fnm completions --shell zsh > $ZDOTDIR/completions/_fnm
  _is_cmd rtx && rtx completion zsh > $ZDOTDIR/completions/_rtx
}

_yomz() {
  _yfplug https://github.com/ohmyzsh/ohmyzsh/raw/master/plugins/$1/$1.plugin.zsh
}

_ysource() {
  [[ -f $1 ]] && source $1
}
