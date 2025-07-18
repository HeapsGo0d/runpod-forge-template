#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

# --- 1. Install & Launch FileBrowser (Optional but Recommended) ---
# Check if FILEBROWSER variable is set to "true"
if [ "$FILEBROWSER" = "true" ]; then
    echo "Starting FileBrowser..."
    # Download and install FileBrowser
    curl -fsSL https://raw.githubusercontent.com/filebrowser/get/master/get.sh | bash
    # Start FileBrowser in the background on port 8080
    # It will serve the /workspace directory with user 'admin' and password 'admin'
    nohup /usr/local/bin/filebrowser -r /workspace -p 8080 -a 0.0.0.0 --auth.method=json --auth.user.username=admin --auth.user.password=admin &
    echo "FileBrowser is running on port 8080. User: admin, Pass: admin"
fi

# --- 2. Clone Repositories (WebUI Forge and Downloader) ---
echo "Cloning required repositories..."
# Clone WebUI Forge if it doesn't already exist
if [ ! -d "/workspace/stable-diffusion-webui-forge" ]; then
    git clone https://github.com/lllyasviel/stable-diffusion-webui-forge.git /workspace/stable-diffusion-webui-forge
fi
# Clone the Civitai Downloader utility
if [ ! -d "/workspace/civitai-downloader" ]; then
    git clone https://github.com/Hearmeman24/CivitAI_Downloader.git /workspace/civitai-downloader
fi

# Navigate to the WebUI directory
cd /workspace/stable-diffusion-webui-forge

# --- 3. Download Models, VAEs, and LoRAs using Environment Variables ---
echo "Starting asset downloads..."
DOWNLOADER_SCRIPT="/workspace/civitai-downloader/download_with_aria.py"

# Download Checkpoints (Main Models)
if [ -n "$CHECKPOINT_IDS_TO_DOWNLOAD" ]; then
    echo "Downloading Checkpoints: $CHECKPOINT_IDS_TO_DOWNLOAD"
    python $DOWNLOADER_SCRIPT --checkpoint-ids $CHECKPOINT_IDS_TO_DOWNLOAD --download-dir models/Stable-diffusion/
fi

# Download LoRAs
if [ -n "$LORA_IDS_TO_DOWNLOAD" ]; then
    echo "Downloading LoRAs: $LORA_IDS_TO_DOWNLOAD"
    python $DOWNLOADER_SCRIPT --lora-ids $LORA_IDS_TO_DOWNLOAD --download-dir models/Lora/
fi

# Download VAEs
if [ -n "$VAE_IDS_TO_DOWNLOAD" ]; then
    echo "Downloading VAEs: $VAE_IDS_TO_DOWNLOAD"
    python $DOWNLOADER_SCRIPT --vae-ids $VAE_IDS_TO_DOWNLOAD --download-dir models/VAE/
fi

echo "All downloads complete."

# --- 4. Launch the WebUI ---
echo "Launching Stable Diffusion WebUI Forge..."

# Set command line arguments for Forge
# --listen: Allows access from outside the container
# --xformers: Performance optimization
# --enable-insecure-extension-access: Needed for many extensions
# --no-half-vae: Improves compatibility with some VAEs
# --theme dark: Personal preference
export COMMANDLINE_ARGS="--listen --xformers --enable-insecure-extension-access --no-half-vae --theme dark --api"

# Execute the launch script. `exec` replaces the current process, which is good practice.
exec python launch.py
