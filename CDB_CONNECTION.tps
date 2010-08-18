CREATE OR REPLACE type ZEKUS.cdb_connection as object (
  /*
    connection object. it holds the host address, port, username and password
    of the couchdb database you want to connect. it can print the connection uri
    and test the connection to the specified database.
    
    set dbms_output on;
    declare
      conn      cdb_connection;
    begin
      conn  := cdb_connection('127.0.0.1', 5984);
      conn.print;
      conn.test;
    end;
    /
    
  */
  host          varchar2(256),
  port          number,
  username      varchar2(256),
  password      varchar2(256),
  uri           varchar2(256),
  
  constructor function cdb_connection(
    host      varchar2,
    port      number,
    username  varchar2:=null,
    password  varchar2:=null) 
    return self as result,
    
  member procedure print,
  member procedure test,
  
  member function get_uri return varchar2
    
);
/
