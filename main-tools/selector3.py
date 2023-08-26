import os
import pandas as pd
class bcolors:
              YELLOW = '\033[1;33m'
              END = '\033[0m'
# Read sum and avg column names from files
def read_column_file(file_name):
    with open(file_name, 'r') as col_file:
        new_column_name = col_file.readline().strip()
        columns = col_file.read().splitlines()
    return new_column_name, columns

# Read sum and avg operation names from file names
sum_column_name, sum_columns = read_column_file('sum-column.txt')
avg_column_name, avg_columns = read_column_file('avg-column.txt')

# Process each CSV file
def process_csv_file(csv_file_path, sum_columns, avg_columns):
    data = pd.read_csv(csv_file_path)
    
    if sum_columns:
        data[sum_column_name + '_sum'] = data[sum_columns].sum(axis=1)
    
    if avg_columns:
        data[avg_column_name + '_avg'] = data[avg_columns].mean(axis=1)
    
    data.to_csv(csv_file_path, index=False)
    print(f"{bcolors.YELLOW}Analysis module processed CSV: {csv_file_path}{bcolors.END}")

# Iterate through directories with -csv in their names
for root, dirs, files in os.walk('query_results'):
    for dir in dirs:
        if dir.endswith('-csv'):
            csv_dir = os.path.join(root, dir)
            
            # Iterate through CSV files
            for file in os.listdir(csv_dir):
                if file.endswith('.csv'):
                    csv_file_path = os.path.join(csv_dir, file)
                    process_csv_file(csv_file_path, sum_columns, avg_columns)
