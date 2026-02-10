-- awr_plan_change - detail of slower
set lines 155
col execs for 999,999,999
col avg_etime for 999,999.999
col avg_lio for 999,999,999.9
col begin_interval_time for a30
col node for 99999
break on plan_hash_value on startup_time skip 1
select ss.snap_id, ss.instance_number node, begin_interval_time, sql_id, plan_hash_value,
nvl(executions_delta,0) execs,
(elapsed_time_delta/decode(nvl(executions_delta,0),0,1,executions_delta))/1000000 avg_etime,
(buffer_gets_delta/decode(nvl(buffer_gets_delta,0),0,1,executions_delta)) avg_lio
from DBA_HIST_SQLSTAT S, DBA_HIST_SNAPSHOT SS
where sql_id in 
    (
            SELECT sql_id
            FROM
              (
                    SELECT sql_id,
                      execs,
                      before_avg_etime,
                      after_avg_etime,
                      norm_stddev,
                      CASE
                        WHEN to_number(before_avg_etime) < to_number(after_avg_etime)
                        THEN 'Slower'
                        ELSE 'Faster'
                      END result
                    FROM
                      (
                            SELECT sql_id,
                              SUM(execs) execs,
                              SUM(before_execs) before_execs,
                              SUM(after_execs) after_execs,
                              SUM(before_avg_etime) before_avg_etime,
                              SUM(after_avg_etime) after_avg_etime,
                              MIN(avg_etime) min_etime,
                              MAX(avg_etime) max_etime,
                              stddev_etime/MIN(avg_etime) norm_stddev,
                              CASE
                                WHEN SUM(before_avg_etime) > SUM(after_avg_etime)
                                THEN 'Slower'
                                ELSE 'Faster'
                              END better_or_worse
                            FROM
                              (  
                                    SELECT sql_id,
                                      period_flag,
                                      execs,
                                      avg_etime,
                                      stddev_etime,
                                      CASE
                                        WHEN period_flag = 'Before'
                                        THEN execs
                                        ELSE 0
                                      END before_execs,
                                      CASE
                                        WHEN period_flag = 'Before'
                                        THEN avg_etime
                                        ELSE 0
                                      END before_avg_etime,
                                      CASE
                                        WHEN period_flag = 'After'
                                        THEN execs
                                        ELSE 0
                                      END after_execs,
                                      CASE
                                        WHEN period_flag = 'After'
                                        THEN avg_etime
                                        ELSE 0
                                      END after_avg_etime
                                    FROM
                                      (  
                                            SELECT sql_id,
                                              period_flag,
                                              execs,
                                              avg_etime,
                                              stddev(avg_etime) over (partition BY sql_id) stddev_etime
                                            FROM
                                              ( 
                                                    SELECT sql_id,
                                                      period_flag,
                                                      SUM(execs) execs,
                                                      SUM(etime)/SUM(DECODE(execs,0,1,execs)) avg_etime
                                                    FROM
                                                      (  
                                                            SELECT sql_id,
                                                              'Before' period_flag,
                                                              NVL(executions_delta,0) execs,
                                                              (elapsed_time_delta)/1000000 etime
                                                            FROM DBA_HIST_SQLSTAT S,
                                                              DBA_HIST_SNAPSHOT SS
                                                            WHERE ss.snap_id            = S.snap_id
                                                            AND ss.instance_number      = S.instance_number
                                                            AND executions_delta        > 0
                                                            AND elapsed_time_delta      > 0
                                                            AND ss.begin_interval_time <= sysdate-1
                                                            UNION
                                                            SELECT sql_id,
                                                              'After' period_flag,
                                                              NVL(executions_delta,0) execs,
                                                              (elapsed_time_delta)/1000000 etime
                                                            FROM DBA_HIST_SQLSTAT S,
                                                              DBA_HIST_SNAPSHOT SS
                                                            WHERE ss.snap_id           = S.snap_id
                                                            AND ss.instance_number     = S.instance_number
                                                            AND executions_delta       > 0
                                                            AND elapsed_time_delta     > 0
                                                            AND ss.begin_interval_time > sysdate-1
                                                      )
                                                    GROUP BY sql_id,
                                                      period_flag
                                              )
                                      )
                              )
                            GROUP BY sql_id,
                              stddev_etime
                      )
                    WHERE norm_stddev > NVL(to_number('2'),2)
                    AND max_etime     > NVL(to_number('0.1'),.1)
              )
            where result = 'Slower'
            -- ORDER BY 6,5
            --   norm_stddev
    )
and ss.snap_id = S.snap_id
and ss.instance_number = S.instance_number
and executions_delta > 0
order by 4, 1, 2, 3
/

