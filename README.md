# Influxdb-tool
Influxdb API tool for sending query automatically .
This tool can take your variable from *.txt file and put them in query and send it to DB with API.


                variable files:               
                host-name.txt -----> name of the hosts have data in DB such as VM name in monitoring service.
                ip_port_list.txt -----> list of influxdb ip and port. for example: localhost:8086
                metric_list.txt -----> dataset of influxdb measurment collected from monitoring system or etc.
                time_range.txt -----> range of UTC time. start and end time of query.
                change yor DB name and min/max/sum/mean values in script file.
