CREATE OR REPLACE procedure ZEKUS.test2 as
  v_res    cdb_utl.t_container;
  a_data   cdb_utl.tab_container;
begin
  cdb_sql.
   sql_for_bulk_api(
    'select trim(mmm01_item_code) "_id", mmm01.* from mmm01@omega where yaa01_code = ''A2'' and mmy41_code = ''46'' and mmy42_code = ''72''',
    null,
    null,
    a_data);


  for i in a_data.first .. a_data.last loop
    cdb_utl.make_request_large(
      'http://10.81.2.100:5984/',
      'POST',
      'dbmerkez/_bulk_docs',
      a_data(i),
      v_res);

    insert into tmp_clob
         values (a_data(i).content, v_res.content);

    commit;
  end loop;

  err.log(1, 'geldim--3');
end;
/