#!/bin/bash

# Function to print file info
print_file_info() {
  local filepath="$1"
  local filename=$(basename "$filepath")

  echo "---BEGIN FILE---"
  echo "---FILENAME START---"
  echo "$filename"
  echo "---FILENAME END---"

  echo "---FILE CONTENT START---"
  if ! output=$(cat "$filepath" 2>/dev/null); then
     echo "***ERROR: Could not read file contents (likely a binary file)***"
  else
     echo "$output"
  fi
  echo "---FILE CONTENT END---"
  echo "---END FILE---"
  echo
}

# Default values
folder=""
exclude_dirs=()

# Parse options
while getopts "f:i:" opt; do
  case ${opt} in
    f) folder="$OPTARG" ;;  # Specify folder
    i) IFS=',' read -ra exclude_dirs <<< "$OPTARG" ;;  # Read exclusions as an array
    *) echo "Usage: $0 -f <folder> [-i <exclude1,exclude2,...>]" ; exit 1 ;;
  esac
done

# Ensure folder is provided
if [[ -z "$folder" ]]; then
  echo "Error: Folder must be specified with -f"
  exit 1
fi

# Convert exclude directories to `-not -path` conditions for `find`
exclude_find=""
for dir in "${exclude_dirs[@]}"; do
  exclude_find+=" -not -path \"$folder/$dir/*\""
done

# Find files while excluding specified directories
eval find \"$folder\" -type f $exclude_find -print0 | while IFS= read -r -d $'\0' file; do
  print_file_info "$file"
done

exit 0
