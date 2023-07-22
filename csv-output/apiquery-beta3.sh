#!/bin/bash

# Set the variables for the script
METRIC_FILE="metric_list.txt"
TIME_RANGE_FILE="time_ranges.txt"
HOST_NAME_FILE="host_names.txt"
IP_PORT_FILE="ip_port_list.txt"
DATABASE="opentsdb"
MEAN_VALUE="mean(\"value\")"

# for bold date font
BOLD="\e[1m"
RESET="\e[0m"

# Read metric names, time ranges, host names, and IP:PORT pairs into separate arrays
IFS=$'\n' read -d '' -r -a METRIC_NAMES < "${METRIC_FILE}"
IFS=$'\n' read -d '' -r -a TIME_RANGES < "${TIME_RANGE_FILE}"
IFS=$'\n' read -d '' -r -a HOST_NAMES < "${HOST_NAME_FILE}"
IFS=$'\n' read -d '' -r -a IP_PORTS < "${IP_PORT_FILE}"

# Output file name
OUTPUT_FILE="query_results.csv"

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
    
    # Format the query result as a CSV row
    local csv_row="\"${metric}\",\"${start_time_range}\",\"${end_time_range}\",\"${host}\",\"${ip_address}\",\"${port}\",\"${query_result}\""
    
    # Append the CSV row to the output file
    echo "$csv_row" >> "$OUTPUT_FILE"
}

# Start by creating an empty output file with header row
echo "Metric,Start Time Range,End Time Range,Host,IP Address,Port,Query Result" > "$OUTPUT_FILE"

# Loop through each combination of metric, time range, host, IP, PORT, and execute the curl command
for metric_name in "${METRIC_NAMES[@]}"; do
    for line in "${TIME_RANGES[@]}"; do
        for host_name in "${HOST_NAMES[@]}"; do
            for ip_port in "${IP_PORTS[@]}"; do
                # Split IP and PORT from the IP:PORT pair
                ip_address="${ip_port%:*}"
                port="${ip_port#*:}"

                # Split the start and end times from the line
                IFS=',' read -r start_time end_time <<< "$line"

                current_date=$(date) && utc_date=$(date -u)

                echo ""
                echo -e "${BOLD}Time Zone Date: ${current_date}${RESET}" && echo -e "${BOLD}UTC Date: ${utc_date}${RESET}"
                echo ""

                # Construct the curl command with the current metric_name, start time, end time, host, IP address, and port
                curl_command="curl -G 'http://${ip_address}:${port}/query' --data-urlencode \"db=${DATABASE}\" --data-urlencode \"q=SELECT ${MEAN_VALUE} FROM \\\"${metric_name}\\\" WHERE (\\\"host\\\" =~ /^${host_name}$/) AND time >= '${start_time}' AND time <= '${end_time}' GROUP BY time(10m) fill(none)\""

                # Print the curl command without evaluation
                printf "Querying metric: %s, Start Time Range: %s, End Time Range: %s, Host: %s, IP Address: %s, Port: %s\n" "$metric_name" "$start_time" "$end_time" "$host_name" "$ip_address" "$port"
                
                # Execute the curl command and append the output to the CSV file
                execute_curl_and_export "$curl_command" "$metric_name" "$start_time" "$end_time" "$host_name" "$ip_address" "$port"
            done
        done
    done
done
