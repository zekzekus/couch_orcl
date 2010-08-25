create or replace type body cdb_document as
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

  constructor function cdb_document(conn cdb_connection, id varchar2 := null)
    return self as result is
  begin
    self.json_data := json_value_array();
    self.check_for_duplicate := 1;

    if id is null then
      self.set_id(cdb_utl.get_uuid());
    else
      self.set_id(id);
    end if;

    self.conn   := conn;
    return;
  end cdb_document;

  member procedure set_id(id varchar2) is
  begin
    self.id     := id;
    self.put('_id', self.id);
  end set_id;

  member procedure set_rev(rev varchar2) is
  begin
    self.rev    := rev;
    self.remove('_rev');
    self.put('_rev', self.rev);
  end set_rev;

  member function print return varchar2 is 
  begin
    return self.to_char(false);
  end print;
  
  member procedure print is
  begin
    cdb_utl.p(self.print);  
  end print;
  
  member procedure save is
    v_res          varchar2(32767);
    j_res          json;
    j_val          json_value;
  begin
    if self.rev is null then
      v_res       :=
        cdb_utl.make_request(
          self.conn.get_uri(),
          'POST',
          self.conn.db_name,
          self.to_char(false));
    else
      v_res       :=
        cdb_utl.make_request(
          self.conn.get_uri(),
          'PUT',
          self.conn.db_name || '/' || self.id,
          self.to_char(false));
    end if;
    j_res       := json_parser.parser(v_res);

    if j_res.get('ok').get_bool() then
      self.set_rev(j_res.get('rev').get_string());
    end if;
    cdb_utl.p(v_res);
  end save;
end;
/