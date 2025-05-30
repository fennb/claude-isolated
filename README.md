# claude-isolated

A Docker-based helper for running Anthropic Claude (or any command) in an isolated, reproducible environment with seamless git branch management.

## Features
- **Isolated Development:** Runs your code in a fresh container, mounting your current git checkout and user config files.
- **Automatic Branching:** Creates a new git branch in the container for safe experimentation.
- **Automatic Sync:** Pushes committed changes back to your original repository only if there are new commits.
- **Configurable Command:** Run any command in the container (defaults to `claude`).
- **Preserves User Config:** Mounts your `.claude`, `.claude.json`, and `.gitconfig` for seamless CLI and git experience.

## Prerequisites
- [Docker](https://www.docker.com/)
- A git repository (run the script from within a git checkout)

## Setup
1. Clone this repository or copy the files into your project.
2. Ensure you have Docker installed and running.

## Usage

### Basic: Run Claude in an Isolated Branch
```sh
./claude-isolated.sh <branch-name>
```
- Creates a new branch `<branch-name>` in the container.
- Runs the `claude` CLI tool.
- On exit, pushes any new commits back to your original repo under `<branch-name>`.

### Advanced: Run a Custom Command
```sh
./claude-isolated.sh <branch-name> <command> [args...]
```
- Runs `<command> [args...]` in the container instead of `claude`.
- Example:
  ```sh
  ./claude-isolated.sh my-feature-branch bash
  ```

## How It Works
- The script builds a Docker image (see `Dockerfile`).
- Mounts your current directory as `/origin-repository` in the container.
- Mounts your `.claude`, `.claude.json`, and `.gitconfig` for config continuity.
- Uses an entrypoint script to:
  - Copy the repo to `/workspace`.
  - Create and track a new branch.
  - Run your command.
  - On exit, push new commits back to your original checkout if there are any.

## Notes
- You must run the script from within a git repository.
- The container uses the `node` user
- The script is safe: it only pushes if there are new, committed changes.
