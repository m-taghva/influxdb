import requests

# InfluxDB settings
influxdb_url = 'http://localhost:8086/query?pretty=true'
database_name = 'opentsdb'

# Define individual queries for each measurement
query1 = "SELECT max(\"value\") FROM \"netdata.system.cpu.user\" WHERE (\"host\" =~ /^m-r1z1s1-controller$/) AND time >= now() - 1m AND time <= now() " 
query2 = "SELECT max(\"value\") FROM \"netdata.system.cpu.system\" WHERE (\"host\" =~ /^m-r1z1s1-controller$/) AND time >= now() - 1m AND time <= now() " 
query3 = "SELECT max(\"value\") FROM \"netdata.system.cpu.nice\" WHERE (\"host\" =~ /^m-r1z1s1-controller$/) AND time >= now() - 1m AND time <= now() " 

# Function to execute a query and get the results as JSON
def execute_influxdb_query(query):
    params = {'db': database_name, 'q': query}
    response = requests.get(influxdb_url, params=params)
    return response.json()

# Execute the queries and merge the results
merged_data = []
queries = [query1, query2, query3]
for query in queries:
    result_json = execute_influxdb_query(query)
    # Assuming the data points are in the 'results' -> 'series' -> 'values' structure
    if 'results' in result_json and 'series' in result_json['results'][0]:
        data_points = result_json['results'][0]['series'][0]['values']
        merged_data.extend(data_points)

# Sort the merged data by time (index 1)
merged_data.sort(key=lambda x: x[1])

sum_value = 0  # Initialize a variable to store the sum of all values

for data_point in merged_data:
    value = data_point[1]
    timestamp = data_point[0]
    print(f"Value: {value} , Time: {timestamp}")
    sum_value += value  # Add the current value to the sum_value

print(f"Sum of all values: {sum_value}")
