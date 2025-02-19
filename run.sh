#!/bin/bash
# # Start a new tmux session named 'distributed_group_chat'
tmux new-session -d -s distributed_group_chat

# # Split the terminal into 2 vertical panes
tmux split-window -h

# # Split the left pane into 3 windows
tmux select-pane -t distributed_group_chat:0.0
tmux split-window -v
tmux select-pane -t distributed_group_chat:0.0
tmux split-window -v

# # Split the right pane horizontally
tmux select-pane -t distributed_group_chat:0.3
tmux split-window -v 

# Select the first pane to start
tmux select-pane -t distributed_group_chat:0.0


# Activate the virtual environment and run the scripts in each pane
run_in_venv() {
    tmux send-keys -t $1 "source .venv/bin/activate && PYTHONPATH=src $2" C-m
}

run_in_venv distributed_group_chat:0.0 "python src/process_runners/run_host.py" C-m
run_in_venv distributed_group_chat:0.1 "chainlit run src/process_runners/run_ui.py --port 8001" C-m
run_in_venv distributed_group_chat:0.3 "python src/process_runners/run_writer_agent.py" C-m
run_in_venv distributed_group_chat:0.4 "python src/process_runners/run_editor_agent.py" C-m
run_in_venv distributed_group_chat:0.2 "python src/process_runners/run_group_chat_manager.py" C-m

# # Attach to the session
tmux attach-session -t distributed_group_chat
