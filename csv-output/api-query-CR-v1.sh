#!/bin/bash

# Set the variables for the script
METRIC_FILE="metric_list.txt"
TIME_RANGE_FILE="time_ranges.txt"
HOST_NAME_FILE="host_names.txt"
IP_PORT_FILE="ip_port_list.txt"
DATABASE="opentsdb"
MEAN_VALUE="mean(\"value\")"

# for bold font
BOLD="\e[1m"
RESET="\e[0m"

# Read metric names, time ranges, host names, and IP:PORT pairs into separate arrays
IFS=$'\n' read -d '' -r -a METRIC_NAMES < "${METRIC_FILE}"
IFS=$'\n' read -d '' -r -a TIME_RANGES < "${TIME_RANGE_FILE}"
IFS=$'\n' read -d '' -r -a HOST_NAMES < "${HOST_NAME_FILE}"
IFS=$'\n' read -d '' -r -a IP_PORTS < "${IP_PORT_FILE}"

# Function to execute the curl command and append the results to the CSV file
execute_curl_and_export() {
    local curl_command="$1"
    local query_result=$(eval "${curl_command}")

    # Extract relevant information from the query result
    local metric="$2"
    local start_time_range="$3"
    local end_time_range="$4"
    local host="$5"
    local ip_address="$6"
    local port="$7"

    # Remove the "netdata" prefix from the metric name
    local clean_metric="${metric#netdata.}"

    # Extract the values from the query result and format them as a comma-separated string
    local values=$(echo "$query_result" | jq -r '.results[0].series[0].values | map(.[1]) | join(",")')

    # Overwrite the CSV row to the host's CSV file
    echo "\"${start_time_range}\",\"${end_time_range}\",\"${values}\"" > "${OUTPUT_DIR}/${host}.csv"
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
    metric_names_row=$(IFS=','; echo "Start Time,End Time,${METRIC_NAMES[*]#netdata.}")
    echo "${metric_names_row}" > "${OUTPUT_DIR}/${host_name}.csv"

    for line in "${TIME_RANGES[@]}"; do
        # Split the start and end times from the line
        IFS=',' read -r start_time end_time <<< "$line"

        # Associative array to store values for each unique timestamp
        declare -A values_map

        for ip_port in "${IP_PORTS[@]}"; do
            # Split IP and PORT from the IP:PORT pair
            ip_address="${ip_port%:*}"
            port="${ip_port#*:}"

            for metric_name in "${METRIC_NAMES[@]}"; do
                # Construct the curl command with the current metric_name, start time, end time, host, IP address, and port
                curl_command="curl -sG 'http://${ip_address}:${port}/query' --data-urlencode \"db=${DATABASE}\" --data-urlencode \"q=SELECT ${MEAN_VALUE} FROM \\\"${metric_name}\\\" WHERE (\\\"host\\\" =~ /^${host_name}$/) AND time >= '${start_time}' AND time <= '${end_time}' GROUP BY time(10m) fill(none)\""

                # Execute the curl command and append the output to the host's CSV file
                query_result=$(eval "${curl_command}")
                values=$(echo "$query_result" | jq -r '.results[0].series[0].values | map(.[1]) | join(",")')

                # Append the values to the corresponding timestamp entry in the associative array
                values_map["$start_time,$end_time"]+=",$values"

                # Update the progress bar
                update_progress
            done
        done
    done

    # Append the collected values for each time range to the CSV file for the host
    for timestamp in $(echo "${!values_map[@]}" | tr " " "\n" | sort); do
        echo "${timestamp}${values_map[$timestamp]}" | tr ' ' ',' >> "${OUTPUT_DIR}/${host_name}.csv"
    done

    # Clear the values_map for the next host
    unset values_map
done

# Print completion message after the progress bar
echo -ne "${BOLD}Progress: [################################################] 100 %${RESET} \n"
echo -e "${BOLD}CSV files are saved in the '$OUTPUT_DIR' directory for each host${RESET}"
