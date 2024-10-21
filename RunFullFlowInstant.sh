#!/bin/bash

PY_ENV_NAME="envTikTokCreator"

# Log file path
LOG_FILE=$(pwd)/logs/script_log.txt

# Function to log both to stdout and to a file
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

log "Script started."

# Sleep for a random amount of time between 2 minutes and 3 hours
# RANDOM_SLEEP=$((120 + RANDOM % 4800))  # Random time between 120 seconds (2 min) and 10800 seconds (1.4 hours)
# log "Sleeping for $RANDOM_SLEEP seconds."
# sleep $RANDOM_SLEEP


export PATH="$HOME/.local/bin:$HOME/bin:/usr/local/bin:/usr/bin:/bin"
export WORKON_HOME="$HOME/.virtualenvs"
export VIRTUALENVWRAPPER_PYTHON="$(which python3)"


# Activate the first virtual environment for RedditVideoMakerBot
log "Activating the virtual environment for RedditVideoMakerBot."
source $(pwd)/$(PY_ENV_NAME)/bin/activate

# Run the Python script
log "Running main.py"
python3 $(pwd)/main.py 2>&1 | tee -a "$LOG_FILE"

# Sleep for 1 minute
log "Sleeping for 60 seconds."
sleep 60

# Find the latest created .mp4 file
log "Finding the latest .mp4 file in the results directory."
latest_file=$(ls -t $(pwd)/results/AmItheAsshole+relationship_advice+confession+tifu/*.mp4 | head -n 1)

if [[ -z "$latest_file" ]]; then
    log "No .mp4 files found! Exiting."
    deactivate  # Deactivate the virtual environment before exiting
    exit 1
else
    log "Found latest file: $latest_file"
fi

# Extract the file name without the .mp4 extension
filename_without_ext=$(basename "$latest_file" .mp4)
log "Extracted file name without extension: $filename_without_ext"

# Generate the word-by-word captions in the latest file with "_out"
log "Generating captions for $latest_file"
python3 $(pwd)/captionGen.py "$latest_file"  --font $(pwd)/fonts/Rubik-Black.ttf  2>&1 | tee -a "$LOG_FILE"

# Update the file path to add the "_out" at the end
latest_file="${latest_file%.mp4}_out.mp4"
log "Updated file name for the captioned version: $latest_file"

# Upload to YouTube
log "Uploading $latest_file to YouTube."
python3 $(pwd)/uploaders/youtubeUpload.py "$latest_file" "$filename_without_ext" 2>&1 | tee -a "$LOG_FILE"

# Upload to Instagram
log "Uploading $latest_file to Instagram."
python3 $(pwd)/uploaders/instaUpload.py "$latest_file" "$filename_without_ext" 2>&1 | tee -a "$LOG_FILE"

# Deactivate the first virtual environment
log "Deactivating RedditVideoMakerBot virtual environment."
deactivate

# Activate the second virtual environment for TikTok uploader
log "Activating the virtual environment for TikTok uploader."
source $(pwd)/uploaders/TiktokAutoUploader/.tokvenv/bin/activate

# Copy to TiktokUploaderSourceFolder
log "Copying $latest_file to TikTok uploader folder."
cp "$latest_file" $(pwd)/uploaders/TiktokAutoUploader/VideosDirPath

# Upload to TikTok
log "Uploading to TikTok using TikTok uploader."
cd $(pwd)/uploaders/TiktokAutoUploader/
python3 cli.py upload --user crazystorylord -v "${filename_without_ext}_out.mp4" -t "$filename_without_ext" 2>&1 | tee -a "$LOG_FILE"

# Deactivate the second virtual environment
log "Deactivating TikTok uploader virtual environment."
deactivate

log "Script completed."
