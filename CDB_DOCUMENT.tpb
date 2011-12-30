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

  constructor function cdb_document(id varchar2 := null)
    return self as result is
    super   json := json();
  begin
    self.json_data := super.json_data;
    self.check_for_duplicate := super.check_for_duplicate;

    if id is null then
      self.set_id(cdb_utl.get_uuid());
    else
      self.set_id(id);
    end if;

    self.conn := null;
    self.deleted := 0;
    return;
  end cdb_document;

  constructor function cdb_document(conn cdb_connection, id varchar2 := null)
    return self as result is
    super   json := json();
  begin
    self.json_data := super.json_data;
    self.check_for_duplicate := super.check_for_duplicate;

    if id is null then
      self.set_id(cdb_utl.get_uuid());
    else
      self.set_id(id);
    end if;

    self.conn := conn;
    self.deleted := 0;
    return;
  end cdb_document;

  member procedure set_id(id varchar2) is
  begin
    self.id := id;
    self.remove('_id');
    self.put('_id', self.id);
  end set_id;

  member procedure set_rev(rev varchar2) is
  begin
    self.rev := rev;
    self.remove('_rev');
    self.put('_rev', self.rev);
  end set_rev;

  member function print
    return varchar2 is
  begin
    return self.to_char(false);
  end print;

  member procedure print is
  begin
    cdb_utl.p(self.print);
  end print;

  member function is_deleted
    return boolean is
  begin
    if self.deleted = 1 then
      return true;
    else
      return false;
    end if;
  end is_deleted;

  member procedure save is
    v_res   cdb_utl.v2_max;
    j_res   json;
    j_val   json_value;
  begin
    if self.conn is null then
      raise_application_error(-20030, 'Can not save without connection object');
    end if;

    if self.is_deleted() then
      raise_application_error(
        -20020,
        'Document is deleted from database: ' || self.id);
    end if;

    if self.rev is null then
      v_res :=
        cdb_utl.make_request(
          self.conn.get_uri(),
          'POST',
          self.conn.db_name,
          self.to_char(false));
    else
      v_res :=
        cdb_utl.make_request(
          self.conn.get_uri(),
          'PUT',
          self.conn.db_name || '/' || self.id,
          self.to_char(false));
    end if;

    j_res := json_parser.parser(v_res);

    begin
      if j_res.get('ok').get_bool() then
        self.set_rev(j_res.get('rev').get_string());
      end if;
    exception
      when others then
        if j_res.exist('error') then
          raise_application_error(
            -20040,
            'error: ' || j_res.get('reason').get_string());
        end if;
    end;
  end save;

  member procedure remove is
    v_res   cdb_utl.v2_max;
    j_res   json;
    j_val   json_value;
  begin
    if self.conn is null then
      raise_application_error(-20030, 'Can not save without connection object');
    end if;

    if self.is_deleted() then
      raise_application_error(
        -20030,
        'Document is already deleted from database: ' || self.id);
    end if;

    if self.rev is null then
      raise_application_error(-20010, 'Document is not saved:' || self.id);
    end if;

    v_res :=
      cdb_utl.
       make_request(
        self.conn.get_uri(),
        'DELETE',
        self.conn.db_name || '/' || self.id || '?rev=' || self.rev);
    j_res := json_parser.parser(v_res);

    begin
      if j_res.get('ok').get_bool() then
        self.deleted := 1;
        self.set_rev(j_res.get('rev').get_string());
      end if;
    exception
      when others then
        if j_res.exist('error') then
          raise_application_error(
            -20040,
            'error: ' || j_res.get('reason').get_string());
        end if;
    end;
  end remove;
end;
/