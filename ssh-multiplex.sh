#!/bin/bash
# Multiplex SSH connections to multiple hosts with simultanious input.

# help / usage - display message if requested, no host or an unsupported option is provided
if [[ $* == "-h" || $* == "--help" || $* == "" || ${*#-} != "$*" ]]; then 
    echo -e "Multiplex SSH connections to multiple hosts with simultanious input.\n"
    echo "Usage: $0 user@host1 [user@host2 ...]"
    echo -e "\nExample: $0 user@host1 user@host2 user@host3 user@host4"
    exit 0
fi 


# set tmux id
ID="SSH-MULTIPLEX"

# check if already inside a tmux session - then create a new window - else create a session
if [ "$TMUX" ]; then
    # session name - from existing tmux session
    SESSION="$(tmux display-message -p '#S')"

    # create first ssh session in a new window inside the tmux session and delete host from list
    i=1
    tmux new-window -t "$SESSION" -n "$ID" -a "ssh $1 ; read -n 1 -p \"Connection to $1 - Press any key to close...\""
    shift

else
    # session name - for a new tmux session
    SESSION="$ID-$$"

    # create first ssh session, detach from it and delete host from list
    i=1
    tmux new-session -s "$SESSION" -n "$ID" -d "ssh $1 ; read -n 1 -p \"Connection to $1 - Press any key to close...\""
    shift

    # disable the tmux status bar
    tmux set-option -t "$SESSION" -n "$ID" status off

fi


# connect the remaining hosts via ssh inside the tmux session and select tiled layout
for i in "$@" ; do
    tmux split-window -t "$SESSION:$ID" "ssh $i ; read -n 1 -p \"Connection to $i - Press any key to close...\""
    tmux select-layout -t "$SESSION:$ID" tiled
done

# synchronize the input
tmux set-window-option -t "$SESSION:$ID" synchronize-panes on

# attach to the newly created tmux session if not already inside
if [ -z "$TMUX" ]; then
    tmux attach-session -t "$SESSION"
fi

