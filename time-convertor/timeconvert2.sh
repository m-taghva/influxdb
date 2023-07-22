#!/bin/bash

# Check if the file is provided as an argument
if [ -z "$1" ]; then
  echo "Error: Please provide the file containing Tehran timestamps as an argument."
  echo "Usage: $0 <filename>"
  exit 1
fi

# Check if the file exists
if [ ! -f "$1" ]; then
  echo "Error: File '$1' not found."
  exit 1
fi

# Read Tehran timestamps from the file and convert them to UTC time
while IFS=',' read -r tehran_timestamp_1 tehran_timestamp_2; do
  # Convert Tehran to UTC time (Unix timestamps)
  utc_timestamp_1=$(date --date "$tehran_timestamp_1" +%s -u)
  utc_timestamp_2=$(date --date "$tehran_timestamp_2" +%s -u)

  # Display the results in one line
  echo -n "Tehran Timestamp 1: $tehran_timestamp_1, UTC Timestamp 1: $(date --date @"$utc_timestamp_1" +"%Y-%m-%d %H:%M:%S"), "
  echo "Tehran Timestamp 2: $tehran_timestamp_2, UTC Timestamp 2: $(date --date @"$utc_timestamp_2" +"%Y-%m-%d %H:%M:%S")"
done < "$1"
