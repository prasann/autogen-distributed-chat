#!/bin/bash
# Stop a new tmux session named 'distributed_group_chat'

session_name="distributed_group_chat"

if tmux has-session -t $session_name 2>/dev/null; then
    tmux kill-session -t $session_name
fi