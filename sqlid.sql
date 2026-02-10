--wait event information for a specific SQL statement from the ASH: 
select
    event,
    time_waited "time_waited(s)",
    case when time_waited = 0 then
        0
    else
        round(time_waited*100 / sum(time_waited) Over(), 2)
    end "percentage"
from
    (
        select event, sum(time_waited) time_waited
        from v$active_session_history
        where sql_id = 'SQL_ID'   --REPLACE THE SQL_ID HERE
        group by event
    )
order by
    time_waited desc;



-- AWR
select
    event,
    time_waited "time_waited(s)",
    case when time_waited = 0 then
        0
    else
        round(time_waited*100 / sum(time_waited) Over(), 2)
    end "percentage"
from
    (
        select event, sum(time_waited) time_waited
        from dba_hist_active_sess_history
        where sql_id = 'SQL_ID'  --REPLACE THE SQL_ID HERE
        group by event
    )
order by
    time_waited desc;


-- V$ACTIVE_SESSION_HISTORY
select
    event,
    sum(time_waited) time_waited
from
    v$active_session_history
where
    sql_id = 'SQL_ID'  -- REPLACE THE SQL_DI HERE
and
    sample_time between
      to_timestamp('START_TIMESTAMP', 'YYYY-MM-DD HH24:MI:SS.FF3') and
      to_timestamp('END_TIMESTAMP', 'YYYY-MM-DD HH24:MI:SS.FF3')     --REPLACE START_TIMESTAMP AND END_TIMESTAMP HERE
group by
    event
order by
    time_waited desc;




-- DBA_HIST_SESS_HISTORY
select
    event,
    sum(time_waited) time_waited
from
    dba_hist_active_sess_history
where
    sql_id = 'SQL_ID'     -- REPLACE THE SQL_DI HERE
and
   sample_time between
     to_timestamp('START_TIMESTAMP', 'YYYY-MM-DD HH24:MI:SS.FF3') and
     to_timestamp('END_TIMESTAMP', 'YYYY-MM-DD HH24:MI:SS.FF3')          --REPLACE START_TIMESTAMP AND END_TIMESTAMP HERE
group by
    event
order by
    time_waited desc;



--SQL VERSION
select
    ssc.*,
    sa.version_count,
    sa.sql_text
from
    v$sqlarea sa
    inner join
    v$sql_shared_cursor ssc
        on sa.address = ssc.address
where
    sa.sql_id = 'SQL_ID'
order by
    ssc.child_number;



--SQL Script to Identify Wait Events Between Snapshots
select distinct
    ash.event,
    ash.sql_id,
    users.username,
    ash.program,
    dbms_lob.substr(sql_text.sql_text, 4000, 1) sql_text
from
    dba_hist_active_sess_history ash
    left outer join
    dba_users users
        on ash.user_id = users.user_id
    left outer join
    dba_hist_sqltext sql_text
        on ash.sql_id = sql_text.sql_id
where
    ash.snap_id between BEGIN_SNAP_ID and END_SNAP_ID   --REPLACE THE BEGIN AND END SNAPSHOT ID HERE
and
    ash.event = 'wait event'

;



--SQL TO RETRIVE SNAPSHOT IDS
    
select DBID, INSTANCE_NUMBER, SNAP_ID, BEGIN_INTERVAL_TIME from DBA_HIST_SNAPSHOT order by 4 asc;


select distinct
    ash.event,
    ash.sql_id,
    users.username,
    ash.program,
    dbms_lob.substr(sql_text.sql_text, 4000, 1) sql_text
from
    dba_hist_active_sess_history ash
    left outer join
    dba_users users
        on ash.user_id = users.user_id
    left outer join
    dba_hist_sqltext sql_text
        on ash.sql_id = sql_text.sql_id
where
    ash.snap_id between 1000 and 1010
and
    ash.event = 'db file sequential read'

