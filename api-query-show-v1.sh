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

# Loop through each combination of metric, time range, host, IP:PORT pair, and execute the curl command
for metric_name in "${METRIC_NAMES[@]}"; do
    for time_range in "${TIME_RANGES[@]}"; do
        for host_name in "${HOST_NAMES[@]}"; do
            for ip_port in "${IP_PORTS[@]}"; do
                # Split IP and PORT from the IP:PORT pair
                ip_address="${ip_port%% *}"
                port="${ip_port#* }"

                # URL-encode the time range to use in the curl command
                encoded_time_range="$(printf "%s" "$time_range" | sed 's/:/%3A/g' | sed 's/+/%2B/g')"

                current_date=$(date) && utc_date=$(date -u)

                echo ""
                echo -e "${BOLD}Time Zone Date: ${current_date}${RESET}" && echo -e "${BOLD}UTC Date: ${utc_date}${RESET}"
                echo ""

                # Construct the curl command with the current metric_name, time range, host, IP address, and port
                curl_command="curl -G 'http://${ip_address}:${port}/query?pretty=true' --data-urlencode \"db=${DATABASE}\" --data-urlencode \"q=SELECT ${MEAN_VALUE} FROM \\\"${metric_name}\\\" WHERE (\\\"host\\\" =~ /^${host_name}$/) AND time >= ${time_range} AND time <= now()\""

                # Print the curl command without evaluation
                printf "Querying metric: %s, Time Range: %s, Host: %s, IP Address: %s, Port: %s\n" "$metric_name" "$time_range" "$host_name" "$ip_address" "$port"
                # Execute the curl command and print the output
                eval "${curl_command}"
                echo "---------------------------------------------------"
            done
        done
    done
done
