#!/bin/bash

# Check if HUGGING_FACE_MODEL is set
if [ -z "${HUGGING_FACE_MODEL}" ]; then
    echo "Error: HUGGING_FACE_MODEL not set"
    exit 1
fi

# Extract org and repo from HUGGING_FACE_MODEL
HF_ORG=$(echo $HUGGING_FACE_MODEL | cut -d'/' -f1)
HF_REPO=$(echo $HUGGING_FACE_MODEL | cut -d'/' -f2)

check_for_model() {
  set -e  # Exit on command errors
  set -x  # Print each command before execution, useful for debugging

  # Set the git credentials using HuggingFace token.
  git config --global credential.helper 'store --file=/tmp/git-credentials'
  echo "https://$HF_USERNAME:$HF_TOKEN@huggingface.co" > /tmp/git-credentials

  TARGET_DIR="/models/$HF_REPO"

  # Check if the target directory exists
  if [ -d "$TARGET_DIR" ]; then
      echo "Model appears to exist in stage. Skipping download..."
  else
      git lfs install
      # Create a temporary directory
      TEMP_DIR=$(mktemp -d)
      echo "\n\n"
      echo "The provided model does not exist in the stage."
      echo "This startup script will download it for you and save to stage. This can take a few minutes."
      echo "This will not need to download on future startups."
      echo "\n\n"
      echo "Cloning the repository into temporary directory..."
      # Clone the repository into the temporary directory
      GIT_TRACE=1 git clone --depth 1 https://huggingface.co/$HF_ORG/$HF_REPO $TEMP_DIR
      cd "$TEMP_DIR"

      echo "Copying contents to model stage..."
      # Copy contents of the temporary directory to TARGET_DIR
      rsync -a --exclude=".git" "$TEMP_DIR/" "$TARGET_DIR/"

      # Clean up temporary directory
      rm -rf "$TEMP_DIR"
  fi

  # Remove the temporary credentials.
  rm /tmp/git-credentials
}

start_service() {
    local module=$1
    local log_file=$2
    local params=${@:3}

    touch $log_file

    echo "Starting $module..."
    python3 -m $module $params > $log_file 2>&1 &

    # Start tailing the logs and send the process to background
    tail -F $log_file &

    echo "Waiting for $module to be ready..."
    while true
    do
      if grep -q "Uvicorn running" $log_file || grep -q "100%" $log_file; then
        break
      fi
      sleep 1
    done

    # Stop tailing the logs after the service is ready
    pkill -P $$ tail

    echo "$module is ready."
}

check_for_model

start_service fastchat.serve.controller controller.log
start_service fastchat.serve.model_worker model_worker.log --model-path /models/$HF_REPO --num-gpus $NUM_GPU --max-gpu-memory $MAX_GPU_MEMORY
start_service fastchat.serve.openai_api_server api.log --host 0.0.0.0 --port 8000

# wait indefinitely
tail -f /dev/null
