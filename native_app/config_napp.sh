#!/bin/bash

# Prompt user for input
read -p "What is the image repository URL in the APPLICATION PACKAGE (SHOW IMAGE REPOSITORIES IN SCHEMA)? " repository_url
read -p "What is your HuggingFace token? " hf_token

# Paths to the files
makefile="./Makefile"
llm_file="./v1/llm.yaml"

# Copy files
cp $makefile.template $makefile
cp $llm_file.template $llm_file

# Replace placeholders in Makefile file using | as delimiter
sed -i "" "s|<<repository_url>>|$repository_url|g" $makefile

# Replace placeholders in LLM file using | as delimiter
sed -i "" "s|<<HF_TOKEN>>|$hf_token|g" $llm_file

echo "Placeholder values have been replaced!"
