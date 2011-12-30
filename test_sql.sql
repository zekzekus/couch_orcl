create or replace procedure cdb_test_sql is
  conn    cdb_connection;
  dlist   cdb_sql.t_doc_list;
begin
  --utl_http.set_proxy('zekeriya.koc:zekeriya@10.80.1.161:8080', '10.81.3.221');
  -- static methods to create a test database
  --cdb_connection.
  --delete_db('http://admin:admin@zekzekus.iriscouch.com/', 'orcl001');
  --cdb_connection.
  --create_db('http://admin:admin@zekzekus.iriscouch.com/', 'orcl001');

  -- create connection to a specific database
  conn :=
    cdb_connection(
      host       => '10.81.3.221',
      port       => 5984,
      db_name    => 'orcl001',
      username   => 'admin',
      password   => 'admin');
  conn.print();

  dlist :=
    cdb_sql.
     executeList(
      'select * from tmp001');

  for i in dlist.first .. dlist.last loop
    dlist(i).conn := conn;
    dlist(i).set_id(dlist(i).get('BARCODE').get_number());
    dlist(i).put('type_', 'barkod');
    dlist(i).save();
  end loop;
end;
/