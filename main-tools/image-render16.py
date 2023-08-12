import sys
import json
import matplotlib.pyplot as plt
from datetime import datetime

# Read input data from command-line argument
query2_output = sys.argv[1]

# Initialize a dictionary to store grouped data
grouped_data = {}

# Process the JSON data
data = json.loads(query2_output)
for entry in data["results"][0]["series"]:
    name = entry["name"]
    columns = entry["columns"]
    values = entry["values"]

    # Extract the mathematical operation from 'n'
    math_operation = columns[1]

    if name not in grouped_data:
        grouped_data[name] = {}

    if columns == ["time", math_operation]:
        if math_operation not in grouped_data[name]:
            grouped_data[name][math_operation] = {"time": [], "values": []}

        grouped_data[name][math_operation]["time"].extend(
            [datetime.strptime(value[0], "%Y-%m-%dT%H:%M:%SZ") for value in values]
        )
        grouped_data[name][math_operation]["values"].extend(
            [value[1] for value in values]
        )

# Create a single figure with subplots for all graphs
for name, operations in grouped_data.items():
    for math_operation, data in operations.items():
        plt.figure(figsize=(10, 6))
        plt.plot(data["time"], data["values"], marker='o', linestyle='-', linewidth=2)
        plt.xlabel("Time")
        plt.ylabel(f"{math_operation.capitalize()} Value")
        plt.title(f"{name} - {math_operation.capitalize()} Value Over Time")
        plt.xticks(rotation=45)
        plt.grid(True)
        plt.tight_layout()

        output_filename = f"{name.replace('.', '_')}_{math_operation}_graph.jpg"
        plt.savefig(output_filename, dpi=300)
        
        # Close the current plot to avoid displaying it in the output window
        plt.close()
