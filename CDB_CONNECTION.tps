/*
    This file is part of couch_orcl.

    couch_orcl is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    couch_orcl is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
*/
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
