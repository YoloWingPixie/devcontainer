#!/bin/bash
set -euo pipefail

source /etc/devcontainer/workspace.env

STATE_ROOT="$HOME/.local/state/$DEVCONTAINER_WORKSPACE_STATE_DIRECTORY"
DIRECTORY_LOG="$STATE_ROOT/directories.log"
RESURRECT_DIRECTORY="$STATE_ROOT/tmux/resurrect"

wait_for() {
    local attempts=$1
    shift

    for ((attempt = 0; attempt < attempts; attempt++)); do
        if "$@"; then
            return 0
        fi
        sleep 0.1
    done

    return 1
}

pane_command_is_vim() {
    [ "$(tmux display-message -p -t recovered:editor '#{pane_current_command}' 2>/dev/null)" = "vim" ]
}

saved_workspace_exists() {
    [ -L "$RESURRECT_DIRECTORY/last" ]
}

restored_session_exists() {
    tmux has-session -t recovered 2>/dev/null
}

verify_shell_discovery() {
    local -a directories

    zsh -fc 'source "$HOME/.config/zsh/workspace.zsh"; ! whence -w z >/dev/null 2>&1'
    [ ! -e "$DIRECTORY_LOG" ]
    ! tmux has-session 2>/dev/null

    zsh -ic 'whence -w z >/dev/null && whence -w zi >/dev/null && whence -w cdirs >/dev/null'

    mkdir -p /tmp/flightline-one /tmp/flightline-two
    zsh -dfi -c '
        source "$HOME/.config/zsh/workspace.zsh"
        cd /
        cd /tmp/flightline-one
        cd "$HOME"
        cd /tmp/flightline-one
        zoxide add /tmp/flightline-two
        eval "z flightline-two"
        [[ "$PWD" = /tmp/flightline-two ]]
        export FZF_DEFAULT_OPTS="--filter=flightline-one --select-1 --exit-0"
        eval "zi flightline-one"
        [[ "$PWD" = /tmp/flightline-one ]]
    '

    mapfile -t directories < <(cdirs)
    [ "${#directories[@]}" -eq 4 ]
    [ "${directories[0]}" = /tmp/flightline-one ]
    [ "${directories[1]}" = /tmp/flightline-two ]
    [ "${directories[2]}" = "$HOME" ]
    [ "${directories[3]}" = / ]
    ! tmux has-session 2>/dev/null
}

verify_tmux_precedence() {
    printf 'set -g @continuum-save-interval 7\nset -g status-right personal\n' > "$HOME/.tmux.conf"
    tmux -L workspace-precedence new-session -d
    [ "$(tmux -L workspace-precedence show-option -gqv @continuum-save-interval)" = 7 ]
    [ "$(tmux -L workspace-precedence show-option -gqv status-right)" = personal ]
    tmux -L workspace-precedence kill-server
    rm "$HOME/.tmux.conf"
}

create_saved_workspace() {
    tmux new-session -d -s recovered -n editor -c "$HOME" "vim /tmp/workspace-recovery.txt"
    tmux new-window -d -t recovered -n services -c /tmp
    tmux split-window -d -h -t recovered:services -c "$HOME"
    tmux split-window -d -h -t recovered:services -c /tmp
    tmux select-layout -t recovered:services even-horizontal >/dev/null

    [ "$(tmux show-option -gqv @continuum-restore)" = on ]
    [ "$(tmux show-option -gqv @continuum-save-interval)" = "$DEVCONTAINER_TMUX_SAVE_INTERVAL_MINUTES" ]
    case $(tmux show-option -gqv status-right) in
        *continuum_save.sh*) ;;
        *) return 1 ;;
    esac

    wait_for 100 pane_command_is_vim
    tmux set-option -gq @continuum-save-last-timestamp 0
    /opt/tmux/plugins/tmux-continuum/scripts/continuum_save.sh
    wait_for 100 saved_workspace_exists
    tmux kill-server
}

save_workspace() {
    verify_shell_discovery
    verify_tmux_precedence
    create_saved_workspace
}

restore_workspace() {
    local -a directories
    local -a paths
    local -a windows

    mapfile -t directories < <(cdirs)
    [ "${directories[0]}" = /tmp/flightline-one ]
    mkdir -p /tmp/flightline-one
    [ "$(zoxide query flightline-one)" = /tmp/flightline-one ]

    tmux new-session -d
    wait_for 100 restored_session_exists
    wait_for 100 pane_command_is_vim

    mapfile -t windows < <(tmux list-windows -t recovered -F '#{window_name}' | sort)
    [ "${#windows[@]}" -eq 2 ]
    [ "${windows[0]}" = editor ]
    [ "${windows[1]}" = services ]
    [ "$(tmux list-panes -t recovered:services | wc -l)" -eq 3 ]

    mapfile -t paths < <(tmux list-panes -t recovered:services -F '#{pane_current_path}' | sort)
    [ "${paths[0]}" = "$HOME" ]
    [ "${paths[1]}" = /tmp ]
    [ "${paths[2]}" = /tmp ]

    tmux list-panes -t recovered:services -F '#{pane_width}' |
        sort -n |
        awk 'NR == 1 { min = $1 } { max = $1 } END { exit max - min > 1 }'

    tmux kill-server
}

save_workspace
restore_workspace
