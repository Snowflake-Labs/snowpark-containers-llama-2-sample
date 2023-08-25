# Use an official Python runtime as a parent image
FROM python:3.8-slim-buster

# Install git and git-lfs
RUN apt-get update && \
    apt-get install -y git curl rsync && \
    curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash && \
    apt-get install git-lfs && \
    git lfs install

# Set the working directory
WORKDIR /app

# Copy the entrypoint script to the container
COPY entrypoint.sh /app/

# Make our script executable
RUN chmod +x /app/entrypoint.sh

# This command runs when the container starts
ENTRYPOINT ["/app/entrypoint.sh"]
