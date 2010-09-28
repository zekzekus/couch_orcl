create or replace procedure cdb_test_sql is
  conn           cdb_connection;
  dlist          cdb_sql.t_doc_list;
begin
  -- static methods to create a test database
  --cdb_connection.delete_db('http://admin:admin@10.81.3.221:5984/', 'orcl001');
  --cdb_connection.create_db('http://admin:admin@10.81.3.221:5984/', 'orcl001');

  -- create connection to a specific database
  conn        :=
    cdb_connection(
      host        => '10.81.3.221',
      port        => 5984,
      db_name     => 'orcl002',
      username    => 'admin',
      password    => 'admin');
  conn.print();

  cdb_sql.
   sql_to_doc(
    'urun',
    'select * from bba_to_aymm_urun@aymm where rownum < 31',
    dlist);

  for i in dlist.first .. dlist.last loop
    dlist(i).conn := conn;
    dlist(i).set_id(dlist(i).get('barcode').get_number());
    dlist(i).save();
  end loop;
end;
/