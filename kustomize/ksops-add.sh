#!/bin/bash

# Script to automatically add all .enc.yaml files from the secrets folder to ksops.yaml

# Define file paths
KSOPS_YAML="./ksops.yaml"
SECRETS_DIR="./secrets"

# Check if ksops.yaml exists
if [ ! -f "$KSOPS_YAML" ]; then
  echo "Error: $KSOPS_YAML file not found"
  exit 1
fi

# Check if secrets directory exists
if [ ! -d "$SECRETS_DIR" ]; then
  echo "Error: $SECRETS_DIR directory not found"
  exit 1
fi

# Find all .enc.yaml files in the secrets directory
SECRET_FILES=$(find "$SECRETS_DIR" -name "*.enc.yaml" | sort)

if [ -z "$SECRET_FILES" ]; then
  echo "No .enc.yaml files found in $SECRETS_DIR"
  exit 1
fi

# Create a temporary file with updated content
cat "$KSOPS_YAML" | awk -v secret_dir="$SECRETS_DIR" '
BEGIN {
  in_files_section = 0
  files_added = 0
}
/^files:/ {
  in_files_section = 1
  print $0
  next
}
/^[a-z]/ {
  # Any line starting with a lowercase letter indicates a new section
  if (in_files_section && !files_added) {
    # If we were in files section and no files were added, add them now
    system("find " secret_dir " -name \"*.enc.yaml\" | sort | sed \"s/^/  - /\"")
    files_added = 1
  }
  # Turn off files section flag
  in_files_section = 0
  print $0
  next
}
in_files_section && /^  - \.\/secrets\/.*\.enc\.yaml/ {
  # Skip existing secrets entries
  next
}
{
  print $0
}
END {
  if (in_files_section && !files_added) {
    # Add files at the end if we were still in the files section
    system("find " secret_dir " -name \"*.enc.yaml\" | sort | sed \"s/^/  - /\"")
  }
}' > "${KSOPS_YAML}.new"

# Compare files to see if there were changes
if diff -q "${KSOPS_YAML}.new" "$KSOPS_YAML" > /dev/null; then
  echo "No changes needed to $KSOPS_YAML"
  rm "${KSOPS_YAML}.new"
else
  # Backup original file
  cp "$KSOPS_YAML" "${KSOPS_YAML}.bak"

  # Replace with new file
  mv "${KSOPS_YAML}.new" "$KSOPS_YAML"

  echo "Successfully updated $KSOPS_YAML with secret files from $SECRETS_DIR"
  echo "Original file backed up to ${KSOPS_YAML}.bak"
fi

# List current files in ksops.yaml for verification
echo -e "\nCurrent files in $KSOPS_YAML:"
grep "^  - " "$KSOPS_YAML"
