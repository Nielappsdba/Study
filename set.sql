set lines 200
col name for a30

select substr(name,1,30) name,substr(value,1,20) value
from v$parameter
where name in ('db_block_size','compatible','cpu_count','db_file_multiblock_read_count' ,'optimizer_mode','sga_target','sort_area_size')
order by name;
