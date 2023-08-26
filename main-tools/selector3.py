import os
import pandas as pd

# Read operation and new column name from the txt file
def read_txt_file(file_path):
    with open(file_path, 'r') as txt_file:
        operation, new_column_name = txt_file.readline().strip().split('-')
        selected_columns = txt_file.read().splitlines()
    return operation, new_column_name, selected_columns

# Get CSV and transformation directory addresses from user
csv_file_address = input("Enter the CSV file address: ")
transformation_directory = input("Enter the transformation directory address: ")

# Process CSV file
def process_csv_file(csv_data, operation, new_column_name, selected_columns):
    if operation == 'sum':
        csv_data[new_column_name] = csv_data[selected_columns].sum(axis=1)
    elif operation == 'avg':
        csv_data[new_column_name] = csv_data[selected_columns].mean(axis=1)
    return csv_data

# Initialize CSV data
csv_data = pd.read_csv(csv_file_address)

# Iterate through txt files in the transformation directory
for txt_file in os.listdir(transformation_directory):
    if txt_file.startswith('t') and txt_file.endswith('.txt'):
        txt_file_path = os.path.join(transformation_directory, txt_file)
        operation, new_column_name, selected_columns = read_txt_file(txt_file_path)
        
        # Process CSV data
        csv_data = process_csv_file(csv_data, operation, new_column_name, selected_columns)

# Save the final processed CSV data in the original CSV file directory
output_csv_name = f"{os.path.splitext(os.path.basename(csv_file_address))[0]}-{os.path.basename(transformation_directory)}.csv"
output_csv_path = os.path.join(os.path.dirname(csv_file_address), output_csv_name)
csv_data.to_csv(output_csv_path, index=False)
print(f"Processed CSV file: {output_csv_path}")
