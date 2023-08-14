import sys
import json
import matplotlib.pyplot as plt
from datetime import datetime
import pytz
import os
import shutil

# Read InfluxDB query result and server name from command-line arguments
query_output = sys.argv[1]
server_name = sys.argv[2]

# Process the JSON data from the InfluxDB query
data = json.loads(query_output)

# Define UTC and Tehran time zones
utc = pytz.timezone('UTC')
tehran = pytz.timezone('Asia/Tehran')

# Convert UTC times to Tehran time
def convert_to_tehran_time(utc_time):
    utc_time = datetime.strptime(utc_time, "%Y-%m-%dT%H:%M:%SZ")
    utc_time = utc.localize(utc_time)
    tehran_time = utc_time.astimezone(tehran)
    return tehran_time

# Create the "query_results" directory if it doesn't exist
if not os.path.exists("query_results"):
    os.makedirs("query_results")

# Extract data and create graphs for each time range
for entry in data["results"]:
    for series in entry["series"]:
        metric_name = series["name"]
        value_column = series["columns"][1]  # Assuming the value column is always at index 1
        values = series["values"]
        
        # Extract time and value data
        times_utc = [convert_to_tehran_time(value[0]) for value in values]
        values = [value[1] for value in values]
        
        plt.figure(figsize=(10, 6))
        plt.plot(times_utc, values, marker='o', linestyle='-', linewidth=2)
        plt.xlabel("Time (Asia/Tehran)")
        plt.ylabel("Value")
        #plt.ylabel(value_column.capitalize())  # Use value column name as ylabel
        plt.title(f"{metric_name} ({value_column.capitalize()}) - Server: {server_name}")
        plt.xticks(rotation=90)
        
        # Format x-axis labels to Tehran time
        x_labels = [time.strftime("%Y-%m-%d %H:%M:%S") for time in times_utc]
        plt.xticks(times_utc, x_labels)
        
        plt.grid(True)
        plt.tight_layout()

        time_range_start = times_utc[0].strftime("%Y-%m-%d %H:%M:%S")
        time_range_end = times_utc[-1].strftime("%Y-%m-%d %H:%M:%S")
        output_filename = f"{server_name}_{metric_name.replace('.', '_')}_{value_column}_{time_range_start}_{time_range_end}_graph.jpg"
        output_filepath = os.path.join("query_results", output_filename)
        plt.savefig(output_filepath, dpi=300)
        plt.close()

print("Images have been generated and moved to the 'query_results' directory.")
