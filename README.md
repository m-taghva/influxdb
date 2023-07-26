# Influxdb-tool
Influxdb API tool for sending query automatically.
This tool can take your variable from *.txt file and put them in query and send it to influxDB with API.

                our default measurements collect from netdata monitoring tool, you should change query format and application to your needs !
               
                variable files:               
                host-name.txt -----> name of the hosts have data in DB such as VM name in monitoring service.
                ip_port_list.txt -----> list of influxdb ip and port. for example: localhost:8086
                metric_list.txt -----> dataset of influxdb measurment collected from monitoring system or etc.
                time_range.txt -----> range of UTC time. start and end time of query.
                time_range_now.txt -----> range of time from your time until now.
                change yor DB name and min/max/sum/mean values in script file.
