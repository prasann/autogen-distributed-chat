# Multi agent distributed orchestration using Autogen

## Prerequisites

- uv: https://github.com/astral-sh/uv
- tmux (required only if running with run.sh): https://github.com/tmux/tmux

## Usage

1. Create the virtual environment and install dependencies using `uv sync`.
2. Add your OpenAI endpoint and API key to `src/config.yaml`.
3. Call `./run.sh` to start the distributed group chat and open the UI in your browser.
