#!/bin/bash

# Set the variables for the script
METRIC_FILES=""
TIME_RANGE_FILE="time_ranges_utc.txt"
HOST_NAME_FILE="host_names.txt"
IP_PORT_FILE="ip_port_list.txt"
DATABASE="opentsdb"

# for bold font
BOLD="\e[1m"
RESET="\e[0m"

# Read metric file paths/names from the user
read -p "Enter metric file paths/names (comma-separated): " METRIC_FILES
IFS=',' read -ra METRIC_FILES_ARRAY <<< "$METRIC_FILES"

# Read time ranges, host names, and IP:PORT pairs into separate arrays
IFS=$'\n' read -d '' -r -a TIME_RANGES < "${TIME_RANGE_FILE}"
IFS=$'\n' read -d '' -r -a HOST_NAMES < "${HOST_NAME_FILE}"
IFS=$'\n' read -d '' -r -a IP_PORTS < "${IP_PORT_FILE}"

# Function to convert UTC timestamp to Tehran time
convert_to_tehran() {
    local utc_timestamp="$1"
    local tehran_timestamp=$(TZ='Asia/Tehran' date -d "${utc_timestamp}" +"%Y-%m-%d %H:%M:%S")
    echo "$tehran_timestamp"
}

# Output directory
OUTPUT_DIR="query_results"

# Create the output directory
mkdir -p "$OUTPUT_DIR"

update_progress() {
    current_query=$((current_query + 1))
    percentage=$((current_query * 100 / total_queries))
    percentage=$((percentage > 100 ? 100 : percentage))  # Clamp percentage to 100
    bar_length=$((percentage / 2))
    bar="$(printf "%${bar_length}s" | tr ' ' '#')"
    echo -ne "Progress: [${bar}] ${percentage}% \r"
}

# Get the total number of queries to be executed
total_queries=$((${#HOST_NAMES[@]} * ${#TIME_RANGES[@]} * ${#IP_PORTS[@]}))
current_query=0

# Loop through each combination of time range, host, IP, PORT, and execute the curl command
for host_name in "${HOST_NAMES[@]}"; do
    # Create a new CSV file for each host
    output_csv="${OUTPUT_DIR}/${host_name}.csv"

    # Initialize the CSV file with the header
    header="Start_Time,End_Time"

    for metric_file in "${METRIC_FILES_ARRAY[@]}"; do
        while IFS= read -r metric_name; do
            # Extract the prefix from the metric filename
            metric_prefix=$(basename "$metric_file" _metric_list.txt)
            header="${header},${metric_prefix}_${metric_name#netdata.}"
        done < "$metric_file"
    done
    echo "$header" > "$output_csv"

    for line in "${TIME_RANGES[@]}"; do
        # Split the start and end times from the line
        IFS=',' read -r start_time_utc end_time_utc <<< "$line"

        # Convert the timestamps to Tehran time
        start_time_tehran=$(convert_to_tehran "$start_time_utc")
        end_time_tehran=$(convert_to_tehran "$end_time_utc")

        for ip_port in "${IP_PORTS[@]}"; do
            # Split IP and PORT from the IP:PORT pair
            ip_address="${ip_port%:*}"
            port="${ip_port#*:}"

            line_values="$start_time_tehran,$end_time_tehran"

            for metric_file in "${METRIC_FILES_ARRAY[@]}"; do
                if [[ -f "$metric_file" ]]; then
                    while IFS= read -r metric_name; do
                        # Extract the prefix from the metric filename
                        metric_prefix=$(basename "$metric_file" _metric_list.txt)
                        
                        # Construct the curl command with the current metric_name, start time, end time, host, IP address, and port
                        curl_command="curl -sG 'http://${ip_address}:${port}/query' --data-urlencode \"db=${DATABASE}\" --data-urlencode \"q=SELECT ${metric_prefix}(\\\"value\\\") FROM \\\"${metric_name}\\\" WHERE (\\\"host\\\" =~ /^${host_name}$/) AND time >= '${start_time_utc}' AND time <= '${end_time_utc}'\""

                        # Execute the curl command and get the values
                        query_result=$(eval "${curl_command}")
                        values=$(echo "$query_result" | jq -r '.results[0].series[0].values[] | .[1]')

                        # Append the values to the line_values string
                        line_values+=",$values"
                    done < "$metric_file"
                else
                    echo "Metric file not found: $metric_file"
                fi
            done

            # Append the line_values to the CSV file
            echo "$line_values" >> "$output_csv"

            # Update the progress bar
            update_progress
        done
    done
done

# Print completion message after the progress bar
echo -ne "Progress: [######################################################] 100% \n"
echo -e "${BOLD}CSV files are saved in the '$OUTPUT_DIR' directory for each host${RESET}"
