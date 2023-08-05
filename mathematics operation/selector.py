import pandas as pd

# Get the input CSV file name from the user
csv_file = input("Enter the CSV file name: ")

# Read the CSV file
data = pd.read_csv(csv_file)

# Get the metric names from the user
metric_names = input("Enter metric names (separated with comma): ").split(',')

# Get the desired operation from the user (sum or average)
operation = input("Enter operation (sum or avg): ")

# Get the desired average column name from the user
as_column_name = input("Enter average or sum column name: ")

# Calculate the chosen operation for the specified metrics
if operation == "sum":
    data[as_column_name] = data[metric_names].sum(axis=1)
elif operation == "avg":
    data[as_column_name] = data[metric_names].mean(axis=1)
else:
    print("Invalid operation choice. Please choose 'sum' or 'average'.")

# Generate the output CSV file name
output_csv_file = csv_file.replace('.csv', f'_{as_column_name}_{operation}.csv')

# Save the updated data back to the output CSV file
data.to_csv(output_csv_file, index=False)

print(f"New CSV file '{output_csv_file}' saved successfully!")
