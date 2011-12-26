create or replace procedure zekus.cdb_test is
  conn           cdb_connection;
  doc1           cdb_document;
begin
  -- static methods to create a test database
  cdb_connection.delete_db('http://admin:admin@zekzekus.iriscouch.com/', 'orcl001');
  cdb_connection.create_db('http://admin:admin@zekzekus.iriscouch.com/', 'orcl001');

  -- create connection to a specific database
  conn        :=
    cdb_connection(
      host        => 'zekzekus.iriscouch.com',
      port        => 80,
      db_name     => 'orcl001',
      username    => 'admin',
      password    => 'admin');
  conn.print();
  
  doc1 := cdb_document(conn);
  doc1.put('name', 'zekeriya');
  doc1.put('age', 27);
  doc1.save();
end;
/