CREATE OR REPLACE type body ZEKUS.cdb_connection as

  constructor function cdb_connection(
    host      varchar2,
    port      number,
    username  varchar2:=null,
    password  varchar2:=null) 
    return self as result as
  begin
    self.host     := host;
    self.port     := port;
    self.username := username;
    self.password := password;
    if username is null then
      self.uri := 'http://'||host||':'||port||'/';
    else
      self.uri := 'http://'||username||':'||password||'@'||host||':'||port||'/';
    end if;
    return;
  end cdb_connection;
  
  member procedure print as
  begin
    cdb_utl.p(self.get_uri);
  end print;
  
  member function get_uri return varchar2 as
  begin
    return self.uri;
  end get_uri;
  
  member procedure test as
  begin
    cdb_utl.p(cdb_utl.info(self.get_uri).to_char(false));
  end test;
end;
/
