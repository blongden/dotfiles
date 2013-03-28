LIGHT_BLUE="\[\033[1;34m\]"
LIGHT_YELLOW="\[\033[1;33m\]"
LIGHT_GREEN="\[\033[1;32m\]"
DARK_GRAY="\[\033[1;30m\]"
COLOR_NONE="\[\e[0m\]"

PATH=/usr/local/php5/bin:/usr/local/bin:/usr/local/sbin:/Users/ben/pear/bin:/usr/local/share/npm/bin:$PATH

if [ -f /usr/local/etc/bash_completion.d/git-completion.bash ]; then
    source /usr/local/etc/bash_completion.d/git-completion.bash
fi

# enable color support of ls and also add handy aliases
if [ "$TERM" != "dumb" ]; then
    export LSCOLORS=ExfxcxdxCxegedabagacad
    alias ls='ls -ltrGF'
fi

if [ -f ~/.bash_aliases ]; then
    source ~/.bash_aliases
fi

if [ -f $(brew --prefix)/etc/bash_completion ]; then
    . $(brew --prefix)/etc/bash_completion
fi

export PS1="$DARK_GRAY[$LIGHT_BLUE\w$DARK_GRAY]\n$DARK_GRAY[\A]$LIGHT_GREEN\$(__git_ps1)$DARK_GRAY\$$COLOR_NONE "
export PROMPT_COMMAND='echo -ne "\033]0;${PWD/#$HOME/~}\007"'

[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"
PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
source "`brew --prefix`/etc/grc.bashrc"

export EDITOR=vim
alias composer="php ~/composer.phar"
