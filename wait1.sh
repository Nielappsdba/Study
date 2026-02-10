#!/bin/ksh
#Resource Profiler - shows which performance metrics Oracle has updated within the last 10 seconds and
#by how much.

sqlplus "/ as sysdba" << EOT 

set pagesize 0 linesize 500 term off feedback off
select
 to_char(sid) || '_' || replace(event,' ','_') event, time_waited
from
 v\$session_event
where
 time_waited > 0
order by
 time_waited,event, sid;
EOT
