# If you come from bash you might have to change your $PATH.
export PATH=/usr/local/bin/:$PATH

# --- plain zsh (replaced oh-my-zsh 2026-10-08) -----------------------------
# HISTFILE / ZSH_COMPDUMP are set in ~/.zshenv.
HISTSIZE=50000
SAVEHIST=10000
setopt extended_history hist_expire_dups_first hist_ignore_dups \
       hist_ignore_space hist_verify share_history
setopt auto_cd auto_pushd pushd_ignore_dups pushd_minus
setopt always_to_end complete_in_word interactive_comments long_list_jobs \
       prompt_subst no_flow_control

# completion: menu select, case-sensitive
autoload -Uz compinit && compinit -d "$ZSH_COMPDUMP"
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# emacs keys; up/down search history by the typed prefix
bindkey -e
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search  '^[OA' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search '^[OB' down-line-or-beginning-search
bindkey '^[[1;5C' forward-word  '^[[1;5D' backward-word
bindkey '^[[H' beginning-of-line '^[[F' end-of-line '^[[3~' delete-char

# prompt: ➜  dir git:(branch) ✗   (robbyrussell look, via vcs_info)
autoload -Uz vcs_info
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' unstagedstr ' %F{yellow}✗'
zstyle ':vcs_info:git:*' stagedstr ' %F{yellow}✗'
zstyle ':vcs_info:git:*' formats ' %F{blue}git:(%F{red}%b%F{blue})%u%c%f'
zstyle ':vcs_info:git:*' actionformats ' %F{blue}git:(%F{red}%b|%a%F{blue})%u%c%f'
precmd() { vcs_info }
PROMPT='%(?:%F{green}%B➜%b:%F{red}%B➜%b) %F{cyan}%c%f${vcs_info_msg_0_} '

alias ls='ls --color=tty'
alias l='ls -lah' la='ls -lAh' ll='ls -lh'
alias ...='../..' ....='../../..'
alias grep='grep --color=auto'

alias ip='curl canhazip.com'
alias mc='mc --skin modarin256-defbg'
alias df='df -h'
alias du='du -d 1 -h'
alias cleandl='find . -mtime +30 -exec rm -rf "{}" \;'


function maybe_create_env {
  EXE='python3'

  if [ ! -z "$1" ]; then
    EXE="python$1"
  fi

  if [ ! -d '.venv' ]; then
    echo 'Creating new python environment in .venv'
    $EXE -m venv .venv
  fi

  echo 'Activating .venv'
  source .venv/bin/activate
}

alias pyenv="maybe_create_env&&python -V"
alias pyt="pip install --upgrade pip&&pip install pytest&&pip freeze > requirements.txt&&pytest"

export PATH="${GOPATH:-$HOME/go}/bin:/usr/local/sbin:$PATH"

alias zzz='systemctl suspend'
alias ssh='kitten ssh'

alias mud="docker start bold_galileo;cd $HOME/Dev/muddev;source evenv/bin/activate;cd aman"

# buddy = this machine's control repo (memory + rebuild plan); dotfiles in scope too
buddy() { cd "$HOME/Dev/buddy" && claude --add-dir "$HOME/dotfiles" "$@"; }

# homelab = home network / Home Assistant / IoT decloud control repo
homelab() { cd "$HOME/Dev/homelab" && claude "$@"; }

# amiga cross compiler
export VBCC=/opt/vbcc
export PATH="$VBCC/bin:$PATH"
export NDK=/home/ben/Dev/Amiga/NDK3.2
export NDK_INC=$NDK/Include/include_h
export NDK_LIB=$NDK/Include/linker_libs

export PATH="$HOME/.local/bin:$PATH"
