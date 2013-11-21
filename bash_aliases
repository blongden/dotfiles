alias df='df -h'
alias du='du -d 1 -h'

alias vu='vagrant up'
alias vh='vagrant halt'
alias vr='vagrant reload'
alias vs='vagrant ssh'

alias gp='git pull origin'
alias gpm='git pull origin master'
alias gpd='git pull origin develop'
alias gpud='git push origin develop'
alias gpum='git push origin master'
alias grd='git rebase develop'

alias vb='vim ~/.bashrc'
alias va='vim ~/.bash_aliases'
alias rb='. ~/.bashrc'
alias ra='. ~/.bash_aliases'
alias ip='curl icanhazip.com'

alias vim='mvim -v'
alias cleandl='find . -mtime +30 -exec rm -rf "{}" \;'
alias getcom='curl -s https://getcomposer.org/installer | php'
alias com='php composer.phar'

alias pz='cd ~/Development/PZ/'

alias locate='mdfind'

alias specwatch='watchmedo shell-command --recursive --command="bin/phpspec"'

hl() {
    highlight -O rtf $1 --line-numbers --font-size 36 --font Inconsolata --style solarized-light -W -J 65 -j 3 | pbcopy
}

