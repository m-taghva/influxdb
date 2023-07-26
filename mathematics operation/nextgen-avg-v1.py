import csv

def read_csv_file(filename):
    data = []
    with open(filename, 'r', newline='') as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            data.append(row)
    return data

def write_csv_file(filename, data):
    with open(filename, 'w', newline='') as csvfile:
        fieldnames = data[0].keys()
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        for row in data:
            writer.writerow(row)

def calculate_average(data, selected_rows):
    selected_values = [float(row['Value']) for row in data if row['Row Number'] in selected_rows]
    return sum(selected_values) / len(selected_values) if len(selected_values) > 0 else 0

def main():
    input_filename = input("Enter the input CSV filename: ")
    output_filename = input_filename.replace('.csv', '_avg.csv')

    data = read_csv_file(input_filename)

    user_selected_rows = input("Enter Row Numbers you want to average (comma-separated): ")
    user_selected_rows = set(user_selected_rows.split(','))

    selected_data = [row for row in data if row['Row Number'] in user_selected_rows]

    average_value = calculate_average(data, user_selected_rows)
    print(f"The average of selected rows is: {average_value}")

    print("\nSelected Rows:")
    for row in selected_data:
        print(row)

    # Create a new row with the average value
    new_row = {
        'Row Number': 'Average',
        'Start Time': '-----',
        'End Time': '-----',
        'Metric': '-----',
        'Value': average_value
    }
    selected_data.append(new_row)

    write_csv_file(output_filename, selected_data)

if __name__ == "__main__":
    main()
