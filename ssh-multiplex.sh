#!/bin/bash
# Multiplex SSH connections to multiple hosts with simultanious input.
# 2023 - Christian Becker - mail@christianbecker.name

# help / usage - display message if requested, no host or an unsupported option is provided
if [[ $* == "-h" || $* == "--help" || $* == "" || ${*#-} != "$*" ]]; then 
    echo -e "Multiplex SSH connections to multiple hosts with simultanious input.\n"
    echo "Usage: $0 user@host1 [user@host2 ...]"
    echo -e "\nExample: $0 user@host1 user@host2 user@host3 user@host4"
    exit 0
fi 


# set tmux id
ID="SSH-MULTIPLEX"

# set ssh command
SSHCMD="ssh _DESTINATION_ ; read -n 1 -p \"Connection to _DESTINATION_ - Press any key to close...\""


# check if already inside a tmux session - then just create a new window in it
if [ "$TMUX" ]; then
    # session name - from existing tmux session
    SESSION="$(tmux display-message -p '#S')"

    # create first ssh session in a new window inside the tmux session and delete host from list
    tmux new-window -t "$SESSION" -n "$ID" -a "${SSHCMD//_DESTINATION_/$1}"
    shift

# if not already inside tmux - create a new session
else
    # session name - for a new tmux session
    SESSION="$ID-$$"

    # create first ssh session in a new tmux session, detach from it and delete host from list
    tmux new-session -s "$SESSION" -n "$ID" -d "${SSHCMD//_DESTINATION_/$1}"
    shift

    # disable the tmux status bar
    tmux set-option -t "$SESSION:$ID" status off

fi


# connect to the remaining hosts via ssh inside the tmux session and select tiled layout
for i in "$@" ; do
    tmux split-window -t "$SESSION:$ID" "${SSHCMD//_DESTINATION_/$i}"
    tmux select-layout -t "$SESSION:$ID" tiled
done


# synchronize the input between all tmux panes
tmux set-window-option -t "$SESSION:$ID" synchronize-panes on

# attach to the newly created tmux session, if not already inside
if [ -z "$TMUX" ]; then
    tmux attach-session -t "$SESSION"
fi

