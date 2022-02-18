# oh-my-zsh Bureau Theme

### NVM

ZSH_THEME_NVM_PROMPT_PREFIX="%B⬡%b "
ZSH_THEME_NVM_PROMPT_SUFFIX=""

### Git [±master ▾●]

ZSH_THEME_GIT_PROMPT_PREFIX="[%{$fg_bold[green]%}±%{$reset_color%}%{$fg_bold[white]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}]"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg_bold[green]%}✓%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_AHEAD="%{$fg[cyan]%}▴%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_BEHIND="%{$fg[magenta]%}▾%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_STAGED="%{$fg_bold[green]%}●%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_UNSTAGED="%{$fg_bold[yellow]%}●%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg_bold[red]%}●%{$reset_color%}"

bureau_git_branch () {
  local ref
  ref=$(command git symbolic-ref HEAD 2> /dev/null) || \
  ref=$(command git rev-parse --short HEAD 2> /dev/null) || return
  echo "${ref#refs/heads/}"
}

bureau_git_status() {
  local result gitstatus

  # check status of files
  gitstatus=$(command git status --porcelain -b 2> /dev/null)
  if [[ -n "$gitstatus" ]]; then
    if $(echo "$gitstatus" | command grep -q '^[AMRD]. '); then
      result+="$ZSH_THEME_GIT_PROMPT_STAGED"
    fi
    if $(echo "$gitstatus" | command grep -q '^.[MTD] '); then
      result+="$ZSH_THEME_GIT_PROMPT_UNSTAGED"
    fi
    if $(echo "$gitstatus" | command grep -q -E '^\?\? '); then
      result+="$ZSH_THEME_GIT_PROMPT_UNTRACKED"
    fi
    if $(echo "$gitstatus" | command grep -q '^UU '); then
      result+="$ZSH_THEME_GIT_PROMPT_UNMERGED"
    fi
  else
    result+="$ZSH_THEME_GIT_PROMPT_CLEAN"
  fi

  # check status of local repository
  if $(echo "$gitstatus" | command grep -q '^## .*ahead'); then
    result+="$ZSH_THEME_GIT_PROMPT_AHEAD"
  fi
  if $(echo "$gitstatus" | command grep -q '^## .*behind'); then
    result+="$ZSH_THEME_GIT_PROMPT_BEHIND"
  fi
  if $(echo "$gitstatus" | command grep -q '^## .*diverged'); then
    result+="$ZSH_THEME_GIT_PROMPT_DIVERGED"
  fi

  if $(command git rev-parse --verify refs/stash &> /dev/null); then
    result+="$ZSH_THEME_GIT_PROMPT_STASHED"
  fi

  echo $result
}

bureau_git_prompt() {
  local gitbranch=$(bureau_git_branch)
  local gitstatus=$(bureau_git_status)
  local info

  if [[ -z "$gitbranch" ]]; then
    return
  fi

  info="${gitbranch:gs/%/%%}"

  if [[ -n "$gitstatus" ]]; then
    info+=" $gitstatus"
  fi

  echo "${ZSH_THEME_GIT_PROMPT_PREFIX}${info}${ZSH_THEME_GIT_PROMPT_SUFFIX}"
}


_PATH="%{$fg_bold[white]%}%~%{$reset_color%}"

if [[ $EUID -eq 0 ]]; then
  _USERNAME="%{$fg_bold[red]%}%n"
  _LIBERTY="%{$fg[red]%}#"
else
  _USERNAME="%{$fg_bold[white]%}%n"
  _LIBERTY="%{$fg[green]%}$"
fi
_USERNAME="$_USERNAME%{$reset_color%}@%m"
_LIBERTY="$_LIBERTY%{$reset_color%}"


get_space () {
  local STR=$1$2
  local zero='%([BSUbfksu]|([FB]|){*})'
  local LENGTH=${#${(S%%)STR//$~zero/}}
  local SPACES=""
  (( LENGTH = ${COLUMNS} - $LENGTH - 1))

  for i in {0..$LENGTH}
    do
      SPACES="$SPACES "
    done

  echo $SPACES
}

_1LEFT="$_USERNAME $_PATH"
_1RIGHT="[%*] "

bureau_precmd () {
  _1SPACES=`get_space $_1LEFT $_1RIGHT`
  print
  print -rP "$_1LEFT$_1SPACES$_1RIGHT"
}

setopt prompt_subst
PROMPT='> $_LIBERTY '
RPROMPT='$(nvm_prompt_info) $(bureau_git_prompt)'

autoload -U add-zsh-hook
add-zsh-hook precmd bureau_precmd
