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
      self.id     := cdb_utl.get_uuid;
    else
      self.id     := id;
    end if;

    self.conn   := conn;
    self.put('_id', self.id);
    return;
  end cdb_document;

  member procedure save is
    v_res          varchar2(32767);
    j_res          json;
    j_val          json_value;
  begin
    v_res       :=
      cdb_utl.make_request(
        self.conn.uri,
        'POST',
        self.conn.db_name,
        self.to_char(false));
     p(v_res);
--    j_res := json_parser.parser(v_res);
--    if j_res.get('ok').get_bool() then
--      self.rev := j_res.get('rev').get_string();
--      self.put('_rev', self.rev);
--    end if;
  end save;
end;
/