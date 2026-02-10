#!/bin/ksh
#Resource Profiler - shows which performance metrics Oracle has updated within the last 10 seconds and
#by how much.

touch znew02.txt
while true
do
mv znew02.txt zold02.txt
sqlplus "/ as sysdba" << EOT > /dev/null
set pagesize 0 linesize 500 term off feedback off
spool znew01.txt 
select
 to_char(sid) || '_' || replace(event,' ','_') event, time_waited
from
 v\$session_event
where
 time_waited > 0
order by
 event, sid;
spool off
EOT
clear
egrep -v 'SQL|pmon_timer|smon_timer|rdbms_ipc_message' znew01.txt > znew02.txt
join zold02.txt znew02.txt | sed 's/_/ /' | awk -f /home/oracle/ora01.awk | sort -nr | awk -f /home/oracle/ora02.awk | sed 's/_/ /g'
sleep 5
done
