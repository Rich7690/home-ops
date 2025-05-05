#!/bin/bash

# Script to encrypt files ending with .sops.yaml using sops
# Output encrypted files will end with .enc.yaml

set -euo pipefail

# Set the directory to search for files (default to current directory)
SEARCH_DIR=${1:-.}

# Check if sops is installed
if ! command -v sops &> /dev/null; then
    echo "Error: sops is not installed. Please install it first."
    echo "Visit https://github.com/mozilla/sops for installation instructions."
    exit 1
fi

# Find all .sops.yaml files
echo "Searching for .sops.yaml files in $SEARCH_DIR..."
FILES=$(find "$SEARCH_DIR" -type f -name "*.sops.yaml")

# Exit if no files found
if [ -z "$FILES" ]; then
    echo "No .sops.yaml files found."
    exit 0
fi

# Process each file
count=0
for file in $FILES; do
    # Generate output filename by replacing .sops.yaml with .enc.yaml
    output_file="${file%.sops.yaml}.enc.yaml"

    echo "Encrypting: $file -> $output_file"

    # Encrypt the file using sops
    if sops --encrypt "$file" > "$output_file"; then
        echo "✓ Successfully encrypted $file"
        count=$((count + 1))
    else
        echo "✗ Failed to encrypt $file"
    fi
done

echo "Encryption complete. Encrypted $count files."
