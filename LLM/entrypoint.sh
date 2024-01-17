#!/bin/bash

# Check if HUGGING_FACE_MODEL is set
if [ -z "${HUGGING_FACE_MODEL}" ]; then
    echo "Error: HUGGING_FACE_MODEL not set"
    exit 1
fi

# Extract org and repo from HUGGING_FACE_MODEL
export HF_ORG=$(echo $HUGGING_FACE_MODEL | cut -d'/' -f1)
export HF_MODEL=$(echo $HUGGING_FACE_MODEL | cut -d'/' -f2)
export TARGET_DIR="/models/$HF_MODEL"
export TARGET_CONFIG="$TARGET_DIR/config.json"

if [ -f "$TARGET_CONFIG" ]; then
    echo "Model appears to exist in stage. Skipping download..."
else
    echo ""
    echo ""
    echo "The provided model does not exist in the stage."
    echo "This startup script will download it for you and save to stage. This can take a few minutes."
    echo "This will not need to download on future startups."
    echo ""
    echo ""
    python /download_model.py
fi

start_service() {
    local module=$1
    local log_file_basename=$2
    local params=${@:3}

    # Generate the current date/hour/minute format
    local datetime_prefix=$(date +"%Y%m%d-%H%M")

    # Modify log_file to include the datetime prefix and models directory
    local log_file="/models/logs/${datetime_prefix}_${log_file_basename}"

    mkdir -p /models/logs
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

start_service fastchat.serve.controller controller.log
start_service fastchat.serve.model_worker model_worker.log --model-path /models/$HF_MODEL --num-gpus $NUM_GPU --max-gpu-memory $MAX_GPU_MEMORY
start_service fastchat.serve.openai_api_server api.log --host 0.0.0.0 --port 8000

# wait indefinitely
tail -f /dev/null
