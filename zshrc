# If you come from bash you might have to change your $PATH.
export PATH=/usr/local/bin/:$PATH

# Path to your oh-my-zsh installation.
export ZSH=/Users/ben/.oh-my-zsh

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="gianu"

DEFAULT_USER="ben"

# Uncomment the following line to use case-sensitive completion.
CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

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
alias cpr='cp-remote'
alias spy-fe="cp-remote watch > /dev/null &; cp-remote exec npm run yves:dev; kill %1"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/ben/Downloads/google-cloud-sdk/path.zsh.inc' ]; then source '/Users/ben/Downloads/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/ben/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then source '/Users/ben/Downloads/google-cloud-sdk/completion.zsh.inc'; fi

function konto {
    kubectl -n antelope-pp exec `kubectl -n antelope-pp get pods | grep $1 | cut -d' ' -f1 | head -n1` -it -- script /dev/null -c bash
}

function kport {
    kubectl -n antelope-pp port-forward `kubectl -n antelope-pp get pods | grep $1 | cut -d' ' -f1 | head -n1` $2
}

function kexec {
    for x in $(kubectl -n antelope-pp get pods | grep $1 | cut -d' ' -f1); do
        kubectl -n antelope-pp exec $x -t -- ${@:2}
    done;
}

function klog {
    for x in $(kubectl -n antelope-pp get pods | grep $1 | cut -d' ' -f1); do
        kubectl -n antelope-pp logs $x -f
    done;
}
alias kg='kubectl -n antelope-pp get'

function git-mirror {
    git pull origin master
    git push gitlab master
}

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
