SET LINESIZE 200
SET PAGESIZE 1000

COLUMN username FORMAT A20
COLUMN event FORMAT A30
COLUMN wait_class FORMAT A15

SELECT NVL(s.username, '(oracle)') AS username,
       s.sid,
       s.serial#,
       sw.event,
       sw.wait_class,
       sw.wait_time,
       sw.seconds_in_wait,
       sw.state
FROM   v$session_wait sw,
       v$session s
WHERE  s.sid = sw.sid
and s.type='USER'
ORDER BY sw.seconds_in_wait DESC;


Select wait_class, sum(time_waited), sum(time_waited)/sum(total_waits)
Sum_Waits
From v$system_wait_class
Group by wait_class
Order by 3 desc;


Select a.event, a.total_waits, a.time_waited, a.average_wait
From v$system_event a, v$event_name b, v$system_wait_class c
Where a.event_id=b.event_id
And b.wait_class#=c.wait_class#
And c.wait_class = '&Enter_Wait_Class'
order by average_wait desc;


    select
        name,
        round(time_secs, 2) time_secs,
        case when time_secs = 0 then 0 else round(time_secs*100 / sum(time_secs) Over(), 2) end pct
    from (
        select e.event Name, e.time_waited / 100 time_secs
        from v$system_event e join v$event_name n on n.name = e.event
        where n.wait_class <> 'Idle' and time_waited > 0
        union
        select 'server CPU', sum(value / 1000000) time_secs
        from v$sys_time_model
        where stat_name in ('background cpu time', 'DB CPU')
    )
    order by time_secs desc;
    
