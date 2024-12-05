# If you come from bash you might have to change your $PATH.
export PATH=/usr/local/bin/:$PATH

# Path to your oh-my-zsh installation.
export ZSH=/Users/ben.longden/.oh-my-zsh

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
#ZSH_THEME="gianu"
ZSH_THEME="robbyrussell"

DEFAULT_USER="ben.longden"

# Uncomment the following line to use case-sensitive completion.
CASE_SENSITIVE="true"

plugins=(git python pyenv golang)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/dsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# eval "$(docker-machine env dinghy)"

alias ip='curl canhazip.com'
alias df='df -h'
alias du='du -d 1 -h'
alias cleandl='find . -mtime +30 -exec rm -rf "{}" \;'

export NVM_DIR="$HOME/.nvm"
[ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"  # This loads nvm

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

# added by Snowflake SnowSQL installer v1.2
export PATH=/Applications/SnowSQL.app/Contents/MacOS:$PATH
export PATH="$HOME/go/bin:/usr/local/sbin:$PATH"

alias ev='cd /Users/ben.longden/Dev/ev-calc; source .venv/bin/activate'
