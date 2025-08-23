#!/bin/bash

# A simple shell script to find all .mp4 files in a directory tree
# and extract the value of the 'WWW' tag from their metadata.

# Check if a directory path was provided as an argument. 
if [ -z "$1" ]; then
  echo "Usage: $0 <directory_path>"
  exit 1
fi

# Store the provided directory path in a variable.
SEARCH_DIR="$1"

# Check if the provided directory exists.
if [ ! -d "$SEARCH_DIR" ]; then
  echo "Error: Directory '$SEARCH_DIR' not found."
  exit 1
fi

echo "Searching for .mp4 files in '$SEARCH_DIR'..."
echo "------------------------------------------------"

# Use 'find' to recursively locate all files ending with .mp4
# and pipe the results to a while loop for processing.
# 'while read -r' is used for safe handling of filenames with spaces.
find "$SEARCH_DIR" -type f -iname "*.mp4" | while read -r file; do
  
  # Use 'exiftool' to extract the 'WWW' tag.
  # The -s3 option is used to output only the tag's value,
  # suppressing the tag name and group information.
  www_tag_value=$(exiftool -s3 -WWW "$file" 2>/dev/null)

  # Check if the tag value is not empty.
  if [ -n "$www_tag_value" ]; then
    # Generate a SHA-256 hash of the WWW tag value.
    # The '<<< "$www_tag_value"' is a here string,
    # which feeds the variable's content as standard input.
    # 'awk' is used to get the first field, which is the hash.
    #www_tag_hash=$(echo -n "$www_tag_value" | md5sum | awk '{print $1}')
	www_tag_hash=$(echo "$www_tag_value" | tr -d '\/.:\\')

    # Print the file path, the extracted tag value, and its hash.
    echo "File: $file"
    echo "WWW Tag: $www_tag_value"
    echo "WWW Tag (MD5 Hash): $www_tag_hash"
    echo "------------------------------------------------"
    wget -O $SEARCH_DIR"genQR/"$www_tag_hash".png" "https://api.qrserver.com/v1/create-qr-code/?size=180x180&data="$www_tag_value
  fi

done

echo "Script finished."
