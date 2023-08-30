#!/bin/bash

# Prompt user for input
read -p "What is the image repository URL (SHOW IMAGE REPOSITORIES IN SCHEMA)? " repository_url
read -p "What warehouse can the Streamlit app use? " warehouse
read -p "What is your HuggingFace username? " hf_username
read -p "What is your HuggingFace token? " hf_token

# Paths to the files
llm_file="./LLM/llm.yaml"
streamlit_file="./streamlit/streamlit.yaml"

# Replace placeholders in LLM file
sed -i "s/<<repository_url>>/$repository_url/g" $llm_file
sed -i "s/<<HF_USERNAME>>/$hf_username/g" $llm_file
sed -i "s/<<HF_TOKEN>>/$hf_token/g" $llm_file

# Replace placeholders in Streamlit file
sed -i "s/<<repository_url>>/$repository_url/g" $streamlit_file
sed -i "s/<<warehouse_name>>/$warehouse/g" $streamlit_file

echo "Placeholder values have been replaced!"
