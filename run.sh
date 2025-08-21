#!/bin/bash
# # Start a new tmux session named 'distributed_group_chat'

session_name="distributed_group_chat"

if tmux has-session -t $session_name 2>/dev/null; then
    echo "Session '$session_name' already exists. Kill it? [y/N]"
    read answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        tmux kill-session -t $session_name
    else
        echo "Aborting."
        exit 1
    fi
fi

tmux new-session -d -s $session_name

# # Split the terminal into 2 vertical panes
tmux split-window -h

# # Split the left pane into 3 windows
tmux select-pane -t $session_name:0.0
tmux split-window -v
tmux select-pane -t $session_name:0.0
tmux split-window -v

# # Split the right pane horizontally
tmux select-pane -t $session_name:0.3
tmux split-window -v

# Select the first pane to start
tmux select-pane -t $session_name:0.0


# Activate the virtual environment and run the scripts in each pane
run_in_venv() {
    tmux send-keys -t $1 "PYTHONPATH=src uv run $2" C-m
}

run_in_venv $session_name:0.0 "src/process_runners/run_host.py" C-m
run_in_venv $session_name:0.1 "chainlit run src/process_runners/run_ui.py --port 8001" C-m
run_in_venv $session_name:0.3 "src/process_runners/run_writer_agent.py" C-m
run_in_venv $session_name:0.2 "src/process_runners/run_group_chat_manager.py" C-m
run_in_venv $session_name:0.4 "src/process_runners/run_editor_agent.py" C-m

# # Attach to the session
tmux attach-session -t $session_name
