create or replace type cdb_document under json
(
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

  id        varchar2(40),
  rev       varchar2(40),
  conn      cdb_connection,
  deleted   number,
  
  constructor function cdb_document(conn cdb_connection, id varchar2:=null)
    return self as result,
  
  member procedure set_id(id varchar2),
  member procedure set_rev(rev varchar2),

  member function print return varchar2,
  member function is_deleted return boolean,

  member procedure print,      
  member procedure save,
  member procedure remove
  
);
/