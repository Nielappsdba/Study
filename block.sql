WITH blocked_resources AS(
    SELECT
        id1,
        id2,
        SUM(ctime)AS blocked_secs,
        COUNT(1)AS blocked_count,
        type
    FROM
        v$lock
    WHERE
        request > 0
    GROUP BY
        type,
        id1,
        id2
),blockers AS(
    SELECT
        l.id1,
        l.id2,
        l.type,
        l.sid,
        br.blocked_secs,
        br.blocked_count
    FROM
        v$lock              l,
        blocked_resources   br
    WHERE
        br.type = l.type
       AND br.id1 = l.id1
        AND br.id2 = l.id2
        AND l.lmode > 0
        AND l.block <> 0
)
SELECT
/*+
MERGE(@"SEL$22")
MERGE(@"SEL$109DB78D")
MERGE(@"SEL$5")
MERGE(@"SEL$38")
MERGE(@"SEL$470E2127")
MERGE(@"SEL$7286615E")
MERGE(@"SEL$62725911")
MERGE(@"SEL$2EC965E0")
MERGE(@"SEL$C8360722")
MERGE(@"SEL$874CA85A")
MERGE(@"SEL$74A24351")
MERGE(@"SEL$71D7A081")
MERGE(@"SEL$7")
MERGE(@"SEL$24")
CARDINALITY(@"SEL$AF73C875" "S"@"SEL$4" 1000)
CARDINALITY(@"SEL$AF73C875" "R"@"SEL$4" 1000)
*/
    b.id1
    || '_'
    || b.id2
    || '_'
    || s.sid
    || '_'
    || s.serial# AS id,
    'SID,SERIAL:'
    || s.sid
    || ','
    || s.serial#
    || ',LOCK_TYPE:'
    || b.type
    || ',PROGRAM:'
    || s.program
    || ',MODULE:'
    || s.module
    || ',ACTION:'
    || s.action
    || ',MACHINE:'
    || s.machine
    || ',OSUSER:'
    || s.osuser
    || ',USERNAME:'
    || s.username AS info,
    b.blocked_secs,
    b.blocked_count
FROM
    v$session   s,
    blockers    b
WHERE
    b.sid = s.sid
;
