LIGHT_BLUE="\[\033[1;34m\]"
LIGHT_YELLOW="\[\033[1;33m\]"
LIGHT_GREEN="\[\033[1;32m\]"
DARK_GRAY="\[\033[1;30m\]"
COLOR_NONE="\[\e[0m\]"

PATH=/usr/local/bin/:$PATH:/Users/ben/pear/bin

#coreutils from homebrew
if [ -f /usr/local/Cellar/coreutils/8.12/aliases ]; then
    source /usr/local/Cellar/coreutils/8.12/aliases
fi

if [ -f /usr/local/etc/bash_completion.d/git-completion.bash ]; then
    source /usr/local/etc/bash_completion.d/git-completion.bash
fi

# enable color support of ls and also add handy aliases
if [ "$TERM" != "dumb" ]; then
    [ -e "$HOME/.dircolors" ] && DIR_COLORS="$HOME/.dircolors"
    [ -e "$DIR_COLORS" ] || DIR_COLORS=""
    eval "`gdircolors -b $DIR_COLORS`"
    alias ls='gls -ltr --color=auto -ltr'
fi

if [ -f ~/.bash_aliases ]; then
    source ~/.bash_aliases
fi

export PS1="$DARK_GRAY[$LIGHT_BLUE\w$DARK_GRAY]\n[\A]$LIGHT_GREEN\$(__git_ps1)$DARK_GRAY\$$COLOR_NONE "
