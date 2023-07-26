#!/bin/bash

# Set the variables for the script
METRIC_FILE="metric_list.txt"
TIME_RANGE_FILE="time_ranges.txt"
HOST_NAME_FILE="host_names.txt"
IP_PORT_FILE="ip_port_list.txt"
DATABASE="opentsdb"
MEAN_VALUE="mean(\"value\")"

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

    # Extract the end value from the query result
    local end_value=$(echo "$query_result" | jq -r '.results[0].series[0].values[-1][1]')

    # Format the query result as a CSV row
    #local csv_row="\"${metric}\",\"${start_time_range}\",\"${end_time_range}\",\"${host}\",\"${ip_address}\",\"${port}\",\"${end_value}\""
    local csv_row="\"${start_time_range}\",\"${end_time_range}\",\"${clean_metric},\"${end_value}\""   
    # Append the CSV row to the host's CSV file
    echo "$csv_row" >> "${OUTPUT_DIR}/${host}.csv"
}

# Output directory
OUTPUT_DIR="query_results"

# Create the output directory
mkdir -p "$OUTPUT_DIR"

# Get the total number of queries to be executed
total_queries=$((${#HOST_NAMES[@]} * ${#METRIC_NAMES[@]} * ${#TIME_RANGES[@]} * ${#IP_PORTS[@]}))
current_query=0

update_progress() {
    current_query=$((current_query + 1))
    percentage=$((current_query * 100 / total_queries))
    bar_length=$((percentage / 2))
    bar="$(printf "%${bar_length}s" | tr ' ' '#')"
    echo -ne "Progress: [${bar}] ${percentage}% \r"
}

# Loop through each combination of metric, time range, host, IP, PORT, and execute the curl command
for host_name in "${HOST_NAMES[@]}"; do
    # Create a new CSV file for each host
    echo "Start Time Range,End Time Range,Metric,Value" > "${OUTPUT_DIR}/${host_name}.csv"

    for metric_name in "${METRIC_NAMES[@]}"; do
        for line in "${TIME_RANGES[@]}"; do
            for ip_port in "${IP_PORTS[@]}"; do
                # Split IP and PORT from the IP:PORT pair
                ip_address="${ip_port%:*}"
                port="${ip_port#*:}"

                # Split the start and end times from the line
                IFS=',' read -r start_time end_time <<< "$line"

                # Construct the curl command with the current metric_name, start time, end time, host, IP address, and port
                curl_command="curl -sG 'http://${ip_address}:${port}/query' --data-urlencode \"db=${DATABASE}\" --data-urlencode \"q=SELECT ${MEAN_VALUE} FROM \\\"${metric_name}\\\" WHERE (\\\"host\\\" =~ /^${host_name}$/) AND time >= '${start_time}' AND time <= '${end_time}' GROUP BY time(10m) fill(none)\""

                # Print the curl command without evaluation
                #printf "Querying metric: %s, Start Time Range: %s, End Time Range: %s, Host: %s, IP Address: %s, Port: %s\n" "$metric_name" "$start_time" "$end_time" "$host_name" "$ip_address" "$port"

                # Execute the curl command and append the output to the host's CSV file
                execute_curl_and_export "$curl_command" "$metric_name" "$start_time" "$end_time" "$host_name" "$ip_address" "$port"

                # Update the progress bar
                update_progress
            done
        done
    done
done

# Print completion message after the progress bar
echo -ne "Progress: [################################################] 100% \n"
echo "Querying completed. CSV files are saved in the '$OUTPUT_DIR' directory."
