# If you come from bash you might have to change your $PATH.
export PATH=/usr/local/bin/:$PATH

# Path to your oh-my-zsh installation.
export ZSH=/Users/blongden/.oh-my-zsh

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
#ZSH_THEME="gianu"
ZSH_THEME="robbyrussell"

DEFAULT_USER="blongden"

# Uncomment the following line to use case-sensitive completion.
CASE_SENSITIVE="true"

plugins=(git zsh-iterm-touchbar asdf)

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
if [ -f '/Users/blongden/Downloads/google-cloud-sdk/path.zsh.inc' ]; then source '/Users/blongden/Downloads/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/blongden/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then source '/Users/blongden/Downloads/google-cloud-sdk/completion.zsh.inc'; fi

function konto {
    kubectl exec `kubectl get pods | grep $1 | cut -d' ' -f1 | head -n1` -it -- script /dev/null -c bash
}

function kport {
    kubectl port-forward `kubectl get pods | grep $1 | cut -d' ' -f1 | head -n1` $2
}

function kexec {
    for x in $(kubectl get pods | grep $1 | cut -d' ' -f1); do
        kubectl exec $x -t -- ${@:2}
    done;
}

function klog {
    for x in $(kubectl -n antelope-pp get pods | grep $1 | cut -d' ' -f1); do
        kubectl logs $x -f
    done;
}
alias kg='kubectl get'

function git-mirror {
    git pull origin master
    git push gitlab master
}

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
export NVM_DIR="$HOME/.nvm"
. "/usr/local/opt/nvm/nvm.sh"
