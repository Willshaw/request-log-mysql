#!/bin/bash

# usage message
usage='import.sh <database> <logfile> (<tablename>)'

# database to insert into and logfile are required
database=$1
logfile=$2

# optional table name to use when creating log table
tablename=$3

# check logfile and database are set
if [ -z "$database" ]
then
      echo "Please specify database: $usage"
fi
if [ -z "$logfile" ]
then
      echo "Please specify a file: $usage"
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
        read -p "Table name not specified, using \"$tablename\" based on log file, is this ok? [Y/n] " yn
        yn=${yn:-y}
        case $yn in
            [Yy]* ) echo "Using $tablename";
                break;;
            [Nn]* ) echo "Exiting, please start again with the format $usage";
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

# Prefix table name with fr_request_log_
tablename="fr_request_log_$tablename"

# add the headers to the log file
rm tmp.log || echo "tmp.log does not exist"
cat ./headers.txt $logfile > tmp.log

# create the table
cat 'create_table.template' | sed "s/TABLENAME/$tablename/g" > create_table.sql
mysql $database < create_table.sql
