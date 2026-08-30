# ~/.zshenv — sourced for every zsh (scripts included), so keep it lean.
# Purpose: keep tool state/history out of $HOME. See also ~/.zshrc (interactive).

# --- XDG base dirs (explicit; these are the defaults) ------------------------
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# state dir for the history files below
[ -d "$XDG_STATE_HOME" ] || mkdir -p "$XDG_STATE_HOME"

# --- redirect dotfile droppings --------------------------------------------
export LESSHISTFILE="$XDG_STATE_HOME/less_history"
export PYTHON_HISTORY="$XDG_STATE_HOME/python_history"      # Python 3.13+
export PSQL_HISTORY="$XDG_STATE_HOME/psql_history"
export SQLITE_HISTORY="$XDG_STATE_HOME/sqlite_history"
export NODE_REPL_HISTORY="$XDG_STATE_HOME/node_repl_history"
export WGETRC="$XDG_CONFIG_HOME/wgetrc"                     # holds hsts-file=
export GOPATH="$XDG_DATA_HOME/go"
export DOCKER_CONFIG="$XDG_CONFIG_HOME/docker"
export TERRAFORM_D="$XDG_DATA_HOME/terraform.d"

# zsh's own state
export HISTFILE="$XDG_STATE_HOME/zsh/history"
export ZSH_COMPDUMP="$XDG_CACHE_HOME/zsh/zcompdump-${HOST}"
mkdir -p "${HISTFILE%/*}" "${ZSH_COMPDUMP%/*}"
