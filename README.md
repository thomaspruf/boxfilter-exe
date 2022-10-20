# boxfilter-exe
Executables for Mac, Unix and Windows.
Clicking at the archive files leads you to a download button.

Boxfilter is a filter for heart rate and other physiological measurements. It discards outliers and retains values with a high proportion of neighbors in a rectangle (box). In other words, it resembles an algorithm used by the human eye, retaining dense bands of points. Here, I provide executables called boxclip for Mac, Linux, and Windows designed to compute the boxfilter for data stored in a comma separated file (.csv, as can be created e.g. in Microsoft Excel©.) Change the name of "boxclipMac" or "boxclipUnix" to boxclip.
The program is called at a minimum with boxclip data.csv (use ./boxclip data.csv on Mac or Linux) where “data.csv” is an example file in the same directory. Analysed will be the columns named x and y for measurement times and signal. Other columns will be ignored. To use other names, such as "time” and “heartrate” use switches (with double minus): boxclip mydata.csv --time=time --signal=heartrate. The time variable may be omitted, which assumes a regular spacing of time.Use --time=auto to do this. A column may be a datetime in the format YYYY.MM-dd HH:MM:SS. Dates will be coverted to Unixtime (s since 1,1,1970). Use boxclip mydata.csv --date=mydate to indicate the column name. The signal column may contain"NA" for data points not available. Main results will be shown in the browser: the signal before and after filtering. Filtered data are saved on disk in box.csv.

To see the help invoke boxclip -h. For a version use boxclip-v. Both with a single minus.

All points with a proportion of neighbors that is higher than clipit will be discarded. Neighbors are points in box (a rectangle) of a certain width and height. All parameters can be be automatically computed, which is done by default. The width and height of the box are not critical, the value of clipit is. To change it use the switch --clipit or simply --c as in boxclip mydata.csv --c=0.6

There may be a minimal value of the signal. Determine with--miny=  . Any point below miny will be discarded. Data points labelled NA will be internally set to a value, the default is 9999. To change this number use --NA=... New data may be stored with or wihout "NA"in the signal.Default is "y" for yes. Change this behavior with --storeNA=n.

An example call: boxclip data.csv --c:0.45 --width=50 --height=5 --time=tme --signal=hr --miny=15 --NA=-50 --storeNA=n

Another call: boxclip mydata.csv --mode=h (use ./boxclip on Mac or Linux)

Author Thomas Ruf thomas.p.ruf@me.com

