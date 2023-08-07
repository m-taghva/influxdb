#!/bin/bash

python3 tz-to-utc.py
sleep 3

# Set the variables for the script
SUM_METRIC_FILE="sum_metric_list.txt"
MEAN_METRIC_FILE="mean_metric_list.txt"
TIME_RANGE_FILE="time_ranges_utc.txt"
HOST_NAME_FILE="host_names.txt"
IP_PORT_FILE="ip_port_list.txt"
DATABASE="opentsdb"
SUM_MEAN_VALUE_PREFIX="sum"
MEAN_MEAN_VALUE_PREFIX="mean"

# for bold font
BOLD="\e[1m"
RESET="\e[0m"

# Read metric names, time ranges, host names, and IP:PORT pairs into separate arrays
IFS=$'\n' read -d '' -r -a SUM_METRIC_NAMES < "${SUM_METRIC_FILE}"
IFS=$'\n' read -d '' -r -a MEAN_METRIC_NAMES < "${MEAN_METRIC_FILE}"
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
    sum_metric_names_row=$(IFS=','; printf "sum_%s," "${SUM_METRIC_NAMES[@]#netdata.}")
    mean_metric_names_row=$(IFS=','; printf "mean_%s," "${MEAN_METRIC_NAMES[@]#netdata.}")
    output_csv="${OUTPUT_DIR}/${host_name}.csv"

    # Initialize the CSV file with the header
    echo "Start Time,End Time,$sum_metric_names_row$mean_metric_names_row" > "$output_csv"

    for line in "${TIME_RANGES[@]}"; do
        # Split the start and end times from the line
        IFS=',' read -r start_time_utc end_time_utc <<< "$line"

        # Convert the timestamps to Tehran time
        start_time_tehran=$(convert_to_tehran "$start_time_utc")
        end_time_tehran=$(convert_to_tehran "$end_time_utc")

        # Associative arrays to store values for each unique timestamp
        declare -A sum_values_map
        declare -A mean_values_map

        for ip_port in "${IP_PORTS[@]}"; do
            # Split IP and PORT from the IP:PORT pair
            ip_address="${ip_port%:*}"
            port="${ip_port#*:}"

            for sum_metric_name in "${SUM_METRIC_NAMES[@]}"; do
                # Construct the curl command with the current metric_name, start time, end time, host, IP address, and port
                curl_command="curl -sG 'http://${ip_address}:${port}/query' --data-urlencode \"db=${DATABASE}\" --data-urlencode \"q=SELECT ${SUM_MEAN_VALUE_PREFIX}(\\\"value\\\") FROM \\\"${sum_metric_name}\\\" WHERE (\\\"host\\\" =~ /^${host_name}$/) AND time >= '${start_time_utc}' AND time <= '${end_time_utc}'\""

                # Execute the curl command and append the output to the host's CSV file
                query_result=$(eval "${curl_command}")
                values=$(echo "$query_result" | jq -r '.results[0].series[0].values | map(.[1]) | join(",")')

                # Append the values to the corresponding timestamp entry in the associative array
                sum_values_map["$start_time_tehran,$end_time_tehran"]+=",$values"

                # Update the progress bar
                update_progress
            done
            
            for mean_metric_name in "${MEAN_METRIC_NAMES[@]}"; do
                # Construct the curl command with the current metric_name, start time, end time, host, IP address, and port
                curl_command="curl -sG 'http://${ip_address}:${port}/query' --data-urlencode \"db=${DATABASE}\" --data-urlencode \"q=SELECT ${MEAN_MEAN_VALUE_PREFIX}(\\\"value\\\") FROM \\\"${mean_metric_name}\\\" WHERE (\\\"host\\\" =~ /^${host_name}$/) AND time >= '${start_time_utc}' AND time <= '${end_time_utc}'\""

                # Execute the curl command and append the output to the host's CSV file
                query_result=$(eval "${curl_command}")
                values=$(echo "$query_result" | jq -r '.results[0].series[0].values | map(.[1]) | join(",")')

                # Append the values to the corresponding timestamp entry in the associative array
                mean_values_map["$start_time_tehran,$end_time_tehran"]+=",$values"

                # Update the progress bar
                update_progress
            done
        done
    done
    
    # Combine sum and mean values for each time range and sort the lines based on start time and end time
    {
        for timestamp in "${!sum_values_map[@]}"; do
            sum_values="${sum_values_map[$timestamp]:-}"
            mean_values="${mean_values_map[$timestamp]:-}"
            echo "${timestamp},${sum_values}${mean_values}" | tr ' ' ' ' | sed 's/,,/,/g'
        done
    } | sort -t',' -k1,2 >> "$output_csv"

    # Clear the values maps for the next host
    unset sum_values_map
    unset mean_values_map
done

# Print completion message after the progress bar
echo -ne "Progress: [######################################################] 100% \n"
echo -e "${BOLD}CSV files are saved in the '$OUTPUT_DIR' directory for each host${RESET}"
