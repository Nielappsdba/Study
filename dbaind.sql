set lines 200
col index_name for a20

select index_name,blevel,leaf_blocks
from dba_indexes
where owner='SYS'
and index_name like 'TB%';
