import pandas as pd
import matplotlib.pyplot as plt

# Take the CSV file name from the user
csv_file = input("Enter the CSV file name: ")

# Load the CSV file into a pandas DataFrame
data = pd.read_csv(csv_file)

# Plot the metrics over time
plt.figure(figsize=(10, 6))  # Adjust the figure size as needed

# Plot each metric
for metric in data.columns[2:]:  # Assuming metrics start from the 3rd column
    plt.plot(data['Start Time'], data[metric], label=metric)

plt.xlabel('Time')
plt.ylabel('Metric Value')
plt.title('Metrics over Time')
plt.legend()  # Show legend for metric labels
plt.xticks(rotation=45)  # Rotate x-axis labels for better readability

# Annotate each data point with metric values below the graph lines
for metric in data.columns[2:]:  # Assuming metrics start from the 3rd column
    for idx, row in data.iterrows():
        plt.annotate(f'{row[metric]:.2f}', (row['Start Time'], row[metric]), textcoords="offset points", xytext=(0, -6), ha='center', fontsize=6)

plt.tight_layout()  # Adjust layout

# Save the plot as a JPEG image with the same name as the input CSV file
output_filename = csv_file.replace('.csv', '_graph.jpg')
plt.savefig(output_filename, dpi=300)

plt.show()
