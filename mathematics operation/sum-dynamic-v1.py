import requests

def execute_influxdb_query(url, query):
    params = {"db": "opentsdb", "q": query}
    response = requests.get(url, params=params)

    if response.status_code == 200:
        return response.json()
    else:
        raise Exception(f"Error executing query: {response.text}")

def sum_query_results(results):
    sum_result = 0
    for record in results['results'][0]['series'][0]['values']:
        sum_result += record[1]
    return sum_result

def main():
    url = 'http://localhost:8086/query?pretty=true'
    num_queries = int(input("Enter the number of queries: "))

    queries = []
    for i in range(num_queries):
        query = input(f"Enter query {i + 1}: ")
        queries.append(query)

    total_sum = 0
    for query in queries:
        results = execute_influxdb_query(url, query)
        sum_result = sum_query_results(results)
        total_sum += sum_result

    print(f"Total sum of query results: {total_sum}")

if __name__ == "__main__":
    main()
