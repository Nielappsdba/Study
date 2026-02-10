select owner, table_name, column_name from all_lobs where segment_name = 'LOB_SEGMENT_NAME';
#Replace LOB_SEGMENT_NAME with the actual name of the LOB segment you want to search for.

column owner format a10;
column table_name format a20;
column column_name format a20;
select owner, table_name, column_name from all_lobs where segment_name = 'SYS_LOB0000110089C00092$$';

OWNER      TABLE_NAME           COLUMN_NAME
---------- -------------------- --------------------
db_user     OLDB_TAB             EXT_DATA
