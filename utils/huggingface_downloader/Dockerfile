# Use an official Python runtime as a parent image
FROM python:3.8-slim-buster

RUN pip3 install --upgrade pip && pip3 install huggingface_hub
# Set the working directory
WORKDIR /app

# Copy the entrypoint script to the container
COPY entrypoint.sh /app/
COPY download_model.py /app/

# Make our script executable
RUN chmod +x /app/entrypoint.sh

# This command runs when the container starts
ENTRYPOINT ["/app/entrypoint.sh"]
