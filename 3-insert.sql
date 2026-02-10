set autotrace off echo off
insert into test_bl(id,status,num_1,num_2,num_3,num_4
                  ,vc_1,vc_2,vc_pad)
select rownum+441511+441511+441511+441511,decode(mod(rownum,100),0,1
              ,0)
,trunc(dbms_random.value(1,20)) 
,trunc(dbms_random.value(1,30)) 
,mod(rownum,10)+1
,mod(rownum,100)+1
,dbms_random.string('U',5)
,lpad(chr(mod(rownum,6)+65),5,chr(mod(rownum,6)+65) )
,lpad('A',100,'A')
from dba_objects
where rownum < 9999999
/
 
begin
  dbms_stats.gather_table_stats(user,'TEST_BL');
END;
/
