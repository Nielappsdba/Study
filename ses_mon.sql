set  pages 120
prompt LONG session
SELECT l.inst_id, l.sid, l.sql_id,
      CAST(INTERVAL '1' SECOND * l.elapsed_seconds AS
            INTERVAL DAY(0) TO SECOND(0)) elapsed,
      CAST(INTERVAL '1' SECOND * l.time_remaining AS
            INTERVAL DAY(0) TO SECOND(0)) time_left,
      LPAD(ROUND(l.sofar / l.totalwork * 100, 2)||'%', 8) "Progress",
      l.message
FROM  gv$session_longops l,
      gv$session s
WHERE  time_remaining > 0
AND    s.sid = l.sid
AND    s.serial# = l.serial#
AND    s.inst_id = l.inst_id;


set  pages 120
column sid              format 999999
column db_user          format a8     heading 'USER'
column db_login_time    format a6     heading 'LOGON'
column program          format a10    heading 'APP_N'
column active_for       format    999 heading 'ACTV|FOR'
column state            format a5     heading 'STATE'
column waiting_for      format    999 heading 'WAIT|FOR'
column event            format a12    heading 'WAIT ON'
column sql_id           format a13    heading 'SQL ID'


select s.sid,
      nvl (s.username, 'SYS') db_user,
      to_char (s.logon_time, 'hh24:mi') db_login_time,
      substr (s.program, 1, 10) program,
      s.last_call_et active_for,
      decode (s.state,
                'WAITING', 'WAIT',
                'WAITED KNOWN TIME', 'NW L',
                'NW S') state,
      decode (s.wait_time, 0, seconds_in_wait, 0) waiting_for,
      substr (s.event, 1, 12) event,
      nvl (s.sql_id, 'Not Executing') sql_id
  FROM v$session s
WHERE s.type = 'USER'
  AND s.status = 'ACTIVE'
  AND s.wait_class != 'Idle';


--
set newpage none
--
set define on
undefine SESSION_ID
--
accept SESSION_ID prompt 'Enter Session ID > '
--
column sid          FORMAT 99999
column username     FORMAT a12
column logt         FORMAT a12 HEADING 'Logon Time'
column sql_start    format a9  heading 'SQL Start'
column last_call_et            heading 'Time at Status'
column module       FORMAT a16 heading 'Module'
column client_info  format a16 heading 'Client Info'
column command      format 999 heading 'cmd'
column taddr        format a8  heading 'TX Addr'
column server                  heading 'Server|Type'
column schemaname   format a12 heading 'Schema|Name'
column type                    heading 'Session|Type'
column sql_id                  heading 'Curr SQL ID'
column prev_sql_id             heading 'Prev SQL ID'
column lockwait     format a8  heading 'Wait Lock|Addr'
column event        format a25 heading 'Waiting For'
column wait_class   format a12 heading 'Wait Class'
column row_wait_obj#           heading 'Object|Waiting On'
column wait_time               heading 'Last Wait Time|(0=Waiting)'
column seconds_in_wait         heading 'Elapsed From|Last Wait'
column blocking_session        heading 'Blocking|Session ID'
column blocking_session_status heading 'Blocking|Sess Status'
--
select sid, 
       username, 
       to_char (logon_time, 'dd/mm hh24:mi') logt, 
       status,
       last_call_et,
       to_char (sql_exec_start, 'HH24:MI:SS') sql_start
from v$session
where sid = &&SESSION_ID;
/
--
select sid, 
       substr (module, 1, 24) module, 
       substr (client_info, 1, 30) client_info,
       server, schemaname, type
from v$session
where sid = &&SESSION_ID
/
--
select sid, 
       sql_id, prev_sql_id, 
       event,
       substr (wait_class, 1, 20) wait_class
from v$session
where sid = &&SESSION_ID
/
--
select sid, 
       lockwait, 
       row_wait_obj#,
       wait_time, seconds_in_wait,
       blocking_session, blocking_session_status
from v$session
where sid = &&SESSION_ID
/
--
column sql_text format a62
--
select sql_id, sql_text from v$sql
where sql_id = (select sql_id from v$session where sid = &&SESSION_ID)
/
--
undefine SESSION_ID
--
set newpage 1
