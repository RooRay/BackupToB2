#!/bin/bash

# Read README.md on https://github.com/RooRay/BackupToB2 before running
# This script is built for Ubuntu 22.04, it may break on other versions, variants of linux or other operating systems

# Set variables - some examples are pre-filled below for you to change
SOURCE_DIR="/root/minecraft-server"
DEST_DIR="/root/minecraft-server/backups-tmp"
BACKBLAZE_APP_KEY_ID="BACKBLAZE-KEY-ID-HERE"
BACKBLAZE_APP_KEY="BACKBLAZE-APP-KEY-HERE"
BACKBLAZE_BUCKET_NAME="NAME-OF-B2-BUCKET-HERE"
DISCORD_WEBHOOK_URL="DISCORD-WEBHOOK-LINK-HERE"

# Function to send Discord webhook with an embed
send_discord_embed() {
    local title=$1
    local description=$2
    local color=$3
    local json='{
        "embeds": [{
            "title": "'"$title"'",
            "description": "'"$description"'",
            "color": '"$color"'
        }]
    }'
    # Append newline character followed by the error message
    description+="\n Error: $error_message"
    # Replace newline characters with '\n' to ensure they are displayed properly in Discord
    json=$(echo "$json" | sed 's/\\n/\\n/g')
    curl -H "Content-Type: application/json" -X POST -d "$json" "$DISCORD_WEBHOOK_URL"
}

# Function to check if the --loud flag is provided
is_loud() {
    [[ "$*" == *--loud* ]]
}

# Check if b2 is installed
if ! command -v b2 &> /dev/null; then
    # Check if pip is installed, and if not, install it
    if ! command -v pip &> /dev/null; then
        echo "pip not found. Installing..."
        sudo apt-get install -y python3-pip
    fi

    # Install b2 via pip
    echo "Installing b2..."
    pip install b2[full] --quiet
fi

# Check if zip is installed
if ! command -v zip &> /dev/null; then
    echo "zip not found. Installing..."
    sudo apt-get install -y zip
fi

# Create a timestamp for the backup
TIMESTAMP=$(date +"%d-%m-%Y_%I-%M-%p")

# Create a copy of the source directory, excluding unwanted folders
rsync -a --exclude='backups-tmp' --exclude='ubuntu' "$SOURCE_DIR/" "$DEST_DIR/$TIMESTAMP/"

# Zip the copied directory
if is_loud "$@"; then
    (cd "$DEST_DIR" && zip -r "$TIMESTAMP.zip" "$TIMESTAMP")
else
    (cd "$DEST_DIR" && zip -q -r "$TIMESTAMP.zip" "$TIMESTAMP")
fi

# Authenticate with Backblaze B2
if ! b2 authorize-account "$BACKBLAZE_APP_KEY_ID" "$BACKBLAZE_APP_KEY" > /dev/null 2>&1; then
    send_discord_embed "Backup Failed" "Authentication with Backblaze B2 failed." 15548997
    exit 1
fi

# Upload the zip file to Backblaze B2
if is_loud "$@"; then
    if ! b2 upload-file "$BACKBLAZE_BUCKET_NAME" "$DEST_DIR/$TIMESTAMP.zip" "$TIMESTAMP.zip" 2>&1; then
        error_message=$(b2 upload-file "$BACKBLAZE_BUCKET_NAME" "$DEST_DIR/$TIMESTAMP.zip" "$TIMESTAMP.zip" 2>&1)
        send_discord_embed "Backup Failed" "Failed to upload backup to Backblaze B2. Error: $error_message" 15548997
        exit 1
    fi
else
    if ! b2 upload-file "$BACKBLAZE_BUCKET_NAME" "$DEST_DIR/$TIMESTAMP.zip" "$TIMESTAMP.zip" > /dev/null 2>&1; then
        send_discord_embed "Backup Failed" "Failed to upload backup to Backblaze B2." 15548997
        exit 1
    fi
fi

# Clean up: Remove the copied directory and zip file
rm -rf "$DEST_DIR/$TIMESTAMP"
rm "$DEST_DIR/$TIMESTAMP.zip"

send_discord_embed "Backup Successful" "Backup completed successfully." 5763719