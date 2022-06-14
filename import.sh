#!/bin/bash

logfile=$1

tablename=$2

if [ -z "$logfile" ]
then
      echo "Please specify a file"
fi

if [ -z "$tablename" ]
then

    # get the date and start/end time from the first and last entry of the log
    firstline=$(head -n 1 $logfile)
    lastline=$(tail -n 1 $logfile)

    # get the date from the first column of the first line
    date=$(echo $firstline | cut -d ' ' -f 1)
    # get the start time from the second column of the first line
    starttime=$(echo $firstline | cut -d ' ' -f 2)
    # get the end time from the second column of the last line
    endtime=$(echo $lastline | cut -d ' ' -f 2)
    
    tablename="$date-$starttime-$endtime"

    while true; do
        read -p "Table name not specified, using \"$tablename\" based on log file, is this ok? (y/n)" yn
    
        case $yn in
            [Yy]* ) echo "Using $tablename";
                break;;
            [Nn]* ) echo "Exiting, please start again with the format import.sh <logfile> <tablename>";
                exit;;
            * ) echo "Please answer y to accept, or n to exit and supply a table name.";;
        esac

    done

fi

echo "Converting \"$tablename\" to mysql safe string"
# convert to lower case and replace all non-alphanumeric characters with an underscore
tablename=$(printf '%s' "$tablename" | tr '[:upper:]' '[:lower:]')
tablename=$(printf '%s' "$tablename" | tr -c '[:alnum:]' '_')
echo " > conversion complete: $tablename"

# add the headers to the log file
rm tmp.log || echo "tmp.log does not exist"
cat ./headers.txt $logfile > tmp.log

