#!/bin/bash
# Multiplex SSH connections to multiple hosts with simultanious input.

# help / usage - display message if requested, no host or an unsupported option is provided
if [[ $* == "-h" || $* == "--help" || $* == "" || ${*#-} != "$*" ]]; then 
    echo -e "Multiplex SSH connections to multiple hosts with simultanious input.\n"
    echo "Usage: $0 user@host1 [user@host2 ...]"
    echo -e "\nExample: $0 user@host1 user@host2 user@host3 user@host4"
    exit 0
fi 


# session name
SESSION="SSH-MULTIPLEX-$$"

# create first ssh session, detach from it and delete host from list
tmux new-session -s "$SESSION" -d "ssh $1 ; read -n 1 -p \"Connection to $1 - Press any key to close...\""
shift

# connect the remaining hosts inside the tmux session and select tiled layout
for i in "$@" ; do
    tmux split-window -t "$SESSION" "ssh $i ; read -n 1 -p \"Connection to $i - Press any key to close...\""
    tmux select-layout -t "$SESSION" tiled
done

# synchronize the input, disable status bar and attach to the tmux session
tmux set-window-option -t "$SESSION" synchronize-panes on
tmux set-option -t "$SESSION" status off
tmux attach-session -t "$SESSION"

