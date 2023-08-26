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
        new_column_name = f"sum.{new_column_name}"
        csv_data[new_column_name] = csv_data[selected_columns].sum(axis=1)
    elif operation == 'avg':
        new_column_name = f"avg.{new_column_name}"
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

# Remove all columns except "start time," "end time," and columns with "sum." or "avg." prefixes
keep_columns = ['Start_Time','End_Time'] + [col for col in csv_data.columns if col.startswith('sum.') or col.startswith('avg.')]
csv_data = csv_data[keep_columns]

# Save the final CSV data as the last CSV file
final_output_csv_name = f"{os.path.splitext(os.path.basename(csv_file_address))[0]}-{os.path.basename(transformation_directory)}.csv"
final_output_csv_path = os.path.join(os.path.dirname(csv_file_address), final_output_csv_name)
csv_data.to_csv(final_output_csv_path, index=False)
print(f"Final processed CSV file: {final_output_csv_path}")

# Remove the intermediate CSV file
if os.path.exists(final_output_csv_path):
    os.remove(csv_file_address)
    print(f"Intermediate CSV file removed: {csv_file_address}")
    # Rename the final CSV file to match the original CSV file's name
    os.rename(final_output_csv_path, csv_file_address)
    print(f"Final CSV file renamed to: {csv_file_address}")
else:
    print("Intermediate CSV file does not exist.")
