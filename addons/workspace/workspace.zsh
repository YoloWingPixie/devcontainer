[[ -o interactive ]] || return 0

source /etc/devcontainer/workspace.env

typeset -g DEVCONTAINER_WORKSPACE_STATE_ROOT="$HOME/.local/state/$DEVCONTAINER_WORKSPACE_STATE_DIRECTORY"
typeset -g DEVCONTAINER_DIRECTORY_LOG="$DEVCONTAINER_WORKSPACE_STATE_ROOT/directories.log"

mkdir -p -- "$DEVCONTAINER_WORKSPACE_STATE_ROOT/zoxide"

function _devcontainer_log_directory() {
  print -r -- "$PWD" >> "$DEVCONTAINER_DIRECTORY_LOG"
}

autoload -Uz add-zsh-hook
add-zsh-hook chpwd _devcontainer_log_directory
_devcontainer_log_directory

export _ZO_DATA_DIR="$DEVCONTAINER_WORKSPACE_STATE_ROOT/zoxide"
eval "$(zoxide init zsh)"
