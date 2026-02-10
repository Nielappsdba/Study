-- Drop table
drop table test_bl;

-- create table
create table test_bl
 (id    number(8) not null
 ,status number(1) not null
 ,num_1     number(3) not null -- random 20
 ,num_2     number(3) -- random 20
 ,num_3     number(5) -- cycle smoothly
 ,num_4     number(5) -- cycle smoothly
 ,vc_1      varchar2(10)
 ,vc_2      varchar2(10)
 ,vc_pad varchar2(2000))
 tablespace users;


insert into test_bl(id,status,num_1,num_2,num_3,num_4
                   ,vc_1,vc_2,vc_pad)
select rownum,decode(mod(rownum,100),0,1
               ,0)
,trunc(dbms_random.value(1,20))
,trunc(dbms_random.value(1,30))
,mod(rownum,10)+1
,mod(rownum,100)+1
,dbms_random.string('U',10)
,lpad(chr(mod(rownum,6)+65),5,chr(mod(rownum,6)+65) )
,lpad('A',100,'A')
from dba_objects
where rownum < 500;

-- now add a pK on the ID
alter table test_bl
add constraint tb_pk primary key (id)
using index
tablespace users;


-- Start gather 

begin
  dbms_stats.gather_table_stats(user,'TEST_BL');
END;
/



