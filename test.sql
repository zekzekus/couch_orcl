declare
  conn           cdb_connection;
  doc1           cdb_document;
  doc2           cdb_document;
begin
  -- static methods to create a test database
  cdb_connection.delete_db('http://admin:admin@10.81.3.221:5984/', 'orcl001');
  cdb_connection.create_db('http://admin:admin@10.81.3.221:5984/', 'orcl001');

  -- create connection to a specific database
  conn        :=
    cdb_connection(
      host        => '10.81.3.221',
      port        => 5984,
      db_name     => 'orcl001',
      username    => 'admin',
      password    => 'admin');
  conn.print();

  -- create a couchdb document based on json object. id parameter can be null
  -- if so document will take its own random guuid.
  doc1        := cdb_document(conn => conn);
  doc2        := cdb_document(conn => conn, id => 'record001');
  doc1.put('name', 'zekeriya');
  doc1.put('surname', 'koc');
  doc1.put('age', 27);
  doc1.put('is_clever', true);
  -- save document for the first time.
  doc1.save();

  -- modify document...
  doc1.put('hasan', 'mahmut');
  doc1.remove('is_clever');
  -- save again
  doc1.save();
  
  doc2.put('test', 'for delete');
  doc2.save();

  -- document deletes itself
  doc2.remove();
end;
/