#!/bin/bash

# Defaults
CONFIG_FILE="backup_paths.conf"

# Parse args
while getopts "d:c:" opt; do
  case $opt in
    d) DEST_DIR="$OPTARG" ;;
    c) CONFIG_FILE="$OPTARG" ;;
    *) echo "Usage: $0 -d <destination_dir> [-c <config_file>]"; exit 1 ;;
  esac
done

# Validate
[ -z "$DEST_DIR" ] && { echo "Error: -d <destination_dir> required!"; exit 1; }
[ ! -f "$CONFIG_FILE" ] && { echo "Error: Config file '$CONFIG_FILE' not found!"; exit 1; }

# Create timestamped backup dir
BACKUP_DIR="$DEST_DIR/backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR" || exit 1
LOG="$BACKUP_DIR/backup.log"

# Backup loop
echo "Backup started at $(date)" > "$LOG"
while IFS= read -r SRC_PATH || [ -n "$SRC_PATH" ]; do
  [ -z "$SRC_PATH" ] && continue  # Skip empty lines
  if [ -e "$SRC_PATH" ]; then
    rsync -av "$SRC_PATH" "$BACKUP_DIR/" >> "$LOG" 2>&1
    echo "Copied: $SRC_PATH" >> "$LOG"
  else
    echo "Warning: $SRC_PATH not found (skipped)" >> "$LOG"
  fi
done < "$CONFIG_FILE"

echo "Backup completed. Log: $LOG"
