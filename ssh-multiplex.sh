#!/bin/bash
# Multiplex SSH connections to multiple hosts with simultanious input.

# help / usage
if [[ ( $@ == "" || $@ == "--help") ||  $@ == "-h" ]]
then 
    echo -e "Multiplex SSH connections to multiple hosts with simultanious input.\n"
    echo "Usage: $0 user@host1 [user@host2 ...]"
    echo -e "\nExample: $0 user@host1 user@host2 user@host3 user@host4"
    exit 0
fi 

# create first ssh session, detach from it and delete host from list
tmux new-session -s "SSH-MULTIPLEX-$$" -d "ssh $1 ; read -n 1 -p \"Connection to $1 - Press any key to close...\""
shift

# connect the remaining hosts inside the tmux session
for i in $* ; do
    tmux split-window -t "SSH-MULTIPLEX-$$" -h "ssh $i ; read -n 1 -p \"Connection to $i - Press any key to close...\""
done

# select tiled layout, synchronize the input, disable status bar and attach to the tmux session
tmux select-layout -t "SSH-MULTIPLEX-$$" tiled
tmux set-window-option -t "SSH-MULTIPLEX-$$" synchronize-panes on
tmux set-option -t "SSH-MULTIPLEX-$$" status off
tmux attach-session -t "SSH-MULTIPLEX-$$"

