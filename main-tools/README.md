All best practice and LTS version of tools in other directories are here !
       
       api-query.sh script work with <time_ranges_utc.txt> & <time_ranges_timestamp.txt> and <tz-to-utc.py> for receive tehran time and convert to utc and send query, after all print csv file with tehran timestamp.  
       It needs : # pip install pytz
      
       In version 2 of api-query we can send 2 type of query with two value sum and mean and show mix of all metrics in csv. we need different metric list file : sum_metric_list.txt and mean_metric_list.txt

       In selector.py script you give csv file name , metrics you want , sum or avg operation , last column name (avg or sum result) then you have new csv file ! 
       this script need to install pandas library : # pip install pandas

       image-rendere.py can create graph of your csv file in jpg format, just enter file name.
       It needs: # pip install pandas matplotlib
       
       variable files:               
            host-name.txt -----> name of the hosts have data in DB such as VM name in monitoring service.
            ip_port_list.txt -----> list of influxdb ip and port. for example: localhost:8086
            metric_list.txt -----> dataset of influxdb measurment collected from monitoring system or etc.
            time_ranges_timestamp.txt -----> range of tehran time zone. start and end time of query. first put your time here and tz-to-utc convert them to UTC.
            time_ranges_utc.txt -----> range of UTC time for query input parameters.
            change yor DB name and min/max/sum/mean values in script file.
