#!/bin/bash

# Check if the dateutils package is installed
if ! command -v dateutils.dconv &>/dev/null; then
  echo "Error: The 'dateutils' package is not installed. Please install it before running this script."
  exit 1
fi

# Check if the file is provided as an argument
if [ -z "$1" ]; then
  echo "Error: Please provide the file containing UTC timestamps as an argument."
  echo "Usage: $0 <filename>"
  exit 1
fi

# Check if the file exists
if [ ! -f "$1" ]; then
  echo "Error: File '$1' not found."
  exit 1
fi

# Read UTC timestamps from the file and convert them to Tehran time
while IFS=',' read -r utc_timestamp_1 utc_timestamp_2; do
  # Convert UTC to Tehran time
  tehran_timestamp_1=$(dateutils.dconv -i "%Y-%m-%dT%H:%M:%SZ" -f "%Y-%m-%d %H:%M:%S" --zone Asia/Tehran "$utc_timestamp_1")
  tehran_timestamp_2=$(dateutils.dconv -i "%Y-%m-%dT%H:%M:%SZ" -f "%Y-%m-%d %H:%M:%S" --zone Asia/Tehran "$utc_timestamp_2")

  # Display the results in one line
  echo "UTC Timestamp 1: $utc_timestamp_1, Tehran Timestamp 1: $tehran_timestamp_1, UTC Timestamp 2: $utc_timestamp_2, Tehran Timestamp 2: $tehran_timestamp_2"
done < "$1"
