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

plugins=(git zsh-iterm-touchbar)

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
alias muddev=". /Users/blongden/Dev/muddev/evenv/bin/activate && cd /Users/blongden/Dev/muddev/aman"
alias apg="apg -M NC -t"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
export NVM_DIR="$HOME/.nvm"
[ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/usr/local/opt/nvm/etc/bash_completion" ] && . "/usr/local/opt/nvm/etc/bash_completion"  # This loads nvm bash_completion

# tabtab source for serverless package
# uninstall by removing these lines or running `tabtab uninstall serverless`
[[ -f /Users/blongden/.nvm/versions/node/v11.6.0/lib/node_modules/serverless/node_modules/tabtab/.completions/serverless.zsh ]] && . /Users/blongden/.nvm/versions/node/v11.6.0/lib/node_modules/serverless/node_modules/tabtab/.completions/serverless.zsh
# tabtab source for sls package
# uninstall by removing these lines or running `tabtab uninstall sls`
[[ -f /Users/blongden/.nvm/versions/node/v11.6.0/lib/node_modules/serverless/node_modules/tabtab/.completions/sls.zsh ]] && . /Users/blongden/.nvm/versions/node/v11.6.0/lib/node_modules/serverless/node_modules/tabtab/.completions/sls.zsh
# tabtab source for slss package
# uninstall by removing these lines or running `tabtab uninstall slss`
[[ -f /Users/blongden/.nvm/versions/node/v11.6.0/lib/node_modules/serverless/node_modules/tabtab/.completions/slss.zsh ]] && . /Users/blongden/.nvm/versions/node/v11.6.0/lib/node_modules/serverless/node_modules/tabtab/.completions/slss.zsh

# Added by serverless binary installer
export PATH="$HOME/.serverless/bin:$PATH"

# tabtab source for packages
# uninstall by removing these lines
[[ -f ~/.config/tabtab/__tabtab.zsh ]] && . ~/.config/tabtab/__tabtab.zsh || true

# added by Snowflake SnowSQL installer v1.2
export PATH=/Applications/SnowSQL.app/Contents/MacOS:$PATH
export PATH="/usr/local/sbin:/usr/local/Cellar/python@3.9/3.9.1_6/Frameworks/Python.framework/Versions/3.9/bin:$PATH"

# Created by `userpath` on 2021-02-10 16:10:51
export PATH="$PATH:/Users/blongden/.local/bin"
export PATH="/usr/local/opt/python@3.8/bin:$PATH"

alias asp_deploy="ssh asphodel@asphodel.world -- '. venv/bin/activate && cd aman && git pull origin master && evennia reload'"

export PATH=$PATH:/usr/local/Cellar/hadoop/3.3.0/bin
