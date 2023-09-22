#!/bin/bash

set -e  # Exit on command errors

export TARGET_DIR="/models/$HF_MODEL"

python /app/download_model.py

# Terminate the script after cloning/pulling
exit 0
