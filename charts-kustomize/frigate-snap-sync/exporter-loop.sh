#!/usr/bin/bash
apt update && apt install -y inotify-tools ca-certificates # TODO: Move this to Dockerfile

echo "Sleeping while we wait for rclone-conf to be created..."
# Wait for rclone config to be created
while [ ! -f /config/rclone.conf ]; do
  sleep 5
done

# Directory to watch for changes
DIR_TO_WATCH=/media/frigate/recordings

# Remote storage name as configured in rclone
REMOTE_NAME=${REMOTE_NAME:-"b2"}

# Remote bucket name
if [ -z "${REMOTE_BUCKET_NAME}" ]; then
   echo "REMOTE_BUCKET_NAME environment variable is not set. Exiting."
   exit 1
fi

# How long to wait between scheduled retries
TIMEOUT_SEC=5

# State directory for storing timestamps
STATE_DIR=${STATE_DIR:-"/media/frigate-snap"}
LAST_SYNC_FILE=${STATE_DIR}/last-sync-time
LAST_COPY_FILE=${STATE_DIR}/last-copy-time

# Sync interval (24 hours in seconds)
SYNC_INTERVAL=${SYNC_INTERVAL:-86400}

# Create state directory if it doesn't exist
mkdir -p ${STATE_DIR}

export RCLONE_FAST_LIST=1

# Function to calculate max-age based on time since last operation
calculate_max_age() {
   local last_time=$1
   local current_time=$(date +%s)
   local time_diff=$(((current_time - last_time)+5))

   # Default to 1h (3600 seconds) if calculation results in 0 or negative
   if [ $time_diff -le 0 ]; then
      echo "3600s"
   else
      echo "${time_diff}s"
   fi
}

# Function to get last sync time from file
get_last_sync_time() {
   if [ -f "${LAST_SYNC_FILE}" ]; then
      cat "${LAST_SYNC_FILE}"
   else
      echo "0"
   fi
}

# Function to get last copy time from file
get_last_copy_time() {
   if [ -f "${LAST_COPY_FILE}" ]; then
      cat "${LAST_COPY_FILE}"
   else
      echo "0"
   fi
}

# Function to update last sync time in file
update_last_sync_time() {
   local sync_time=$1
   echo "${sync_time}" > "${LAST_SYNC_FILE}"
}

# Function to update last copy time in file
update_last_copy_time() {
   local copy_time=$1
   echo "${copy_time}" > "${LAST_COPY_FILE}"
}

while true; do
   # Get last sync time from ConfigMap
   LAST_SYNC=$(get_last_sync_time)
   CURRENT_TIME=$(date +%s)
   SYNC_TIME_DIFF=$((CURRENT_TIME - LAST_SYNC))

   if [ $SYNC_TIME_DIFF -ge $SYNC_INTERVAL ]; then
      echo "Running scheduled sync (last sync was ${SYNC_TIME_DIFF} seconds ago)..."
      rclone --config /config/rclone.conf sync "${DIR_TO_WATCH}" ${REMOTE_NAME}:${REMOTE_BUCKET_NAME} -v --fast-list --b2-hard-delete --stats-one-line-date --stats 5s 2>&1

      # Update state file with current sync time
      NEW_SYNC_TIME=$(date +%s)
      echo "Updating state file with sync time: ${NEW_SYNC_TIME}"
      update_last_sync_time ${NEW_SYNC_TIME}
   fi

   # Run inotifywait with a timeout
   # Wait for events: close_write
   inotifywait --timeout 60 --event close_write --recursive "${DIR_TO_WATCH}"

   # Store the return value
   status=$?

   if [ $status -eq 0 ] || [ $status -eq 2 ]; then
      echo "File change detected, running incremental copy..."

      # Calculate max-age based on last copy time
      LAST_COPY=$(get_last_copy_time)
      MAX_AGE=$(calculate_max_age $LAST_COPY)
      echo "Using max-age: ${MAX_AGE}"

      NEW_COPY_TIME=$(date +%s) # get the current time before copy to catch changes during copy
      rclone --config /config/rclone.conf copy "${DIR_TO_WATCH}" ${REMOTE_NAME}:${REMOTE_BUCKET_NAME} -I -v --no-traverse --max-age ${MAX_AGE} --stats-one-line-date --stats 5s 2>&1

      # Update state file with current copy time
      echo "Updating state file with copy time after file change: ${NEW_COPY_TIME}"
      update_last_copy_time ${NEW_COPY_TIME}
   else
      echo "inotifywait failed. Waiting before trying again..."
      sleep ${TIMEOUT_SEC}
   fi
done
