CREATE OR REPLACE type body ZEKUS.cdb_connection as
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
      along with couch_orcl.  If not, see <http://www.gnu.org/licenses/>.
  */

  constructor function cdb_connection(
    host            varchar2,
    port            number,
    db_name         varchar2,
    username        varchar2 := null,
    password        varchar2 := null)
    return self as result as
  begin
    self.host   := host;
    self.port   := port;
    self.username := username;
    self.password := password;
    self.db_name := db_name;

    if username is null then
      self.uri    := 'http://' || host || ':' || port || '/';
    else
      self.uri    :=
           'http://'
        || username
        || ':'
        || password
        || '@'
        || host
        || ':'
        || port
        || '/';
    end if;

    return;
  end cdb_connection;

  member procedure print as
  begin
    cdb_utl.p(self.get_uri());
  end print;

  member function get_uri
    return varchar2 as
  begin
    return self.uri;
  end get_uri;

  member procedure test as
  begin
    cdb_utl.p(cdb_utl.server_info(self.get_uri()).to_char(false));
  end test;

  static procedure create_db(db_uri varchar2, db_name varchar2) as
  begin
    cdb_utl.p(cdb_utl.db_create(db_uri, db_name).to_char(false));
  end create_db;

  static procedure delete_db(db_uri varchar2, db_name varchar2) as
  begin
    cdb_utl.p(cdb_utl.db_delete(db_uri, db_name).to_char(false));
  end delete_db;
end;
/
