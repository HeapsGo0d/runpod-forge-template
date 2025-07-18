# Use a RunPod base image with CUDA and Python pre-installed
FROM runpod/pytorch:2.2.0-py3.11-cuda12.1.1-devel-ubuntu22.04

# Set the working directory
WORKDIR /

# Install system dependencies, including the high-speed downloader aria2
RUN apt-get update && \
    apt-get install -y git aria2 wget && \
    rm -rf /var/lib/apt/lists/*

# Copy the startup script into the container
COPY start.sh /start.sh

# Make the startup script executable
RUN chmod +x /start.sh

# This is the command that will run when the container starts
CMD ["/start.sh"]
