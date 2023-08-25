#!/bin/bash

set -e  # Exit on command errors
set -x  # Print each command before execution, useful for debugging

# Set the git credentials using HuggingFace token.
git config --global credential.helper 'store --file=/tmp/git-credentials'
echo "https://$HF_USERNAME:$HF_TOKEN@huggingface.co" > /tmp/git-credentials

git lfs install

TARGET_DIR="/models/$HF_MODEL"

# Check if the target directory exists
if [ -d "$TARGET_DIR" ]; then
    echo "Directory already exists, copying model to temporary directory..."
    cp -r "$TARGET_DIR" /tmp/target_copy
    cd /tmp/target_copy
    
    # Check if the .git directory exists in target_copy
    if [ ! -d ".git" ]; then
        # If not, initialize and add the remote
        git init
        git remote add origin https://huggingface.co/$HF_ORG/$HF_MODEL
    fi

    export GIT_TRACE=1
    git fetch --depth 1
    git reset --hard origin/main   # Reset to the latest state of the remote main branch
    git lfs checkout
    git lfs status

    # Merge changes back to the original directory
    echo "Moving into models stage..."
    rsync -av --exclude=".git" --delete /tmp/target_copy/ "$TARGET_DIR/"
else
    # Create a temporary directory
    TEMP_DIR=$(mktemp -d)

    echo "Cloning the repository into temporary directory..."
    # Clone the repository into the temporary directory
    git clone --depth 1 https://huggingface.co/$HF_ORG/$HF_MODEL $TEMP_DIR
    cd "$TEMP_DIR"

    echo "Copying contents to model stage..."
    # Copy contents of the temporary directory to TARGET_DIR
    rsync -a --exclude=".git" "$TEMP_DIR/" "$TARGET_DIR/"

    # Clean up temporary directory
    rm -rf "$TEMP_DIR"
fi

# Remove the temporary credentials.
rm /tmp/git-credentials

# Terminate the script after cloning/pulling
exit 0
