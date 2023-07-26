these python scripts can take many queries and do mathematical formula on them !

     static version have 3 queries change and use.
     dynamic version take many input queries. 
     for example: SELECT mean("value") FROM "netdata.system.cpu.user" WHERE ("host" =~ /^m-r1z1s1-controller$/) AND time >= now() - 10m AND time <= now() GROUP BY time(10m) fill(none)
     *-csv file can export average or sum query output to one csv file.
     nextgen-avg script can receive your csv file name and each rows you need then make average of them in new csv file (_avg.csv).
