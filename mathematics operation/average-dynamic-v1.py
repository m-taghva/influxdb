import requests

def execute_influxdb_query(url, query):
    params = {"db": "opentsdb", "q": query}
    response = requests.get(url, params=params)

    if response.status_code == 200:
        return response.json()
    else:
        raise Exception(f"Error executing query: {response.text}")

def calculate_average(results):
    total_sum = 0
    total_points = 0
    for record in results['results'][0]['series'][0]['values']:
        total_sum += record[1]
        total_points += 1

    if total_points > 0:
        return total_sum / total_points
    else:
        return 0

def main():
    url = 'http://localhost:8086/query?pretty=true'
    num_queries = int(input("Enter the number of queries: "))

    queries = []
    for i in range(num_queries):
        query = input(f"Enter query {i + 1}: ")
        queries.append(query)

    total_average = 0
    for query in queries:
        results = execute_influxdb_query(url, query)
        query_average = calculate_average(results)
        total_average += query_average

    if num_queries > 0:
        total_average /= num_queries

    print(f"Average of query results: {total_average}")

if __name__ == "__main__":
    main()
