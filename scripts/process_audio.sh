#!/bin/bash

SOURCE_DIR="audio_hays_raw"
TARGET_DIR="audio_processed"
MAX_PARALLEL=10

mkdir -p "$TARGET_DIR"

# Function to process a single file
process_file() {
    local src="$1"
    local filename=$(basename "$src")
    local target="$TARGET_DIR/$filename"

    if [ -f "$target" ]; then
        echo "Skipping $filename (already exists)"
        return
    fi

    echo "Processing $filename..."
    ffmpeg -y -i "$src" -c:a libmp3lame -b:a 32k -ar 22050 -map_metadata -1 -write_xing 0 -id3v2_version 0 -flush_packets 1 "$target" > /dev/null 2>&1
}

export -f process_file
export TARGET_DIR
export SOURCE_DIR

# Find all mp3 files and process them in parallel
find "$SOURCE_DIR" -name "*.mp3" -print0 | xargs -0 -n 1 -P "$MAX_PARALLEL" -I {} bash -c 'process_file "{}"'

echo "Finished processing all files."
