# request-log-mysql
Convert a fusion reactor request log to a mysql table

## Prerequisites

You linux user needs to have a `~/.my.cnf` file setup, and the user needs to be able to create tables

## Usage

Pass in a Fusion Reactor request log file and a table name, to turn the log file into a mysql table

```
./import.sh <logfile> <tablename>
```

Alternatively, just pass in the log file and a table name will be built from the date date of the first line, and the times from the first and last line, e.g. `<date>-<earliest_time>-<latest_time>`
