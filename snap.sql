select
    snap_id,
    dbid,
    instance_number,
    begin_interval_time,
    end_interval_time
from
    dba_hist_snapshot
order by
    snap_id desc;
