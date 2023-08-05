this script save your output in one csv file and append or overwrite data.

         same as api-query.sh need variable files *.txt
         
         *TR can take start and end time in time_range.txt. like this foramt: 2023-07-19T11:20:00Z,2023-07-19T11:30:00Z
         
         *TN can take start time until now in time_range.txt like this format: '2023-07-19T11:20:00Z'
         
         CR version can show csv output with different format of row & column and with brief mode.
        
         ### best practice version is: CR utc version work with <time_ranges_utc.txt> & <time_ranges_timestamp.txt> and <tz-to-utc.py> for receive tehran time and convert to utc and send query, after all print csv file with tehran timestamp.
         It need : # pip install pytz
         
         In seperator version we have one csv file for each host name and befor run script you should install jq package. 
         # apt install jq
         # yum install jq
         
