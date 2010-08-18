CREATE OR REPLACE type ZEKUS.cdb_connection as object (
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
