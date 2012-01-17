CREATE OR REPLACE package body ZEKUS.cdb_sql as
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

  procedure send_bulk_docs(
    p_sql     in            varchar2,
    p_binds   in            json default null,
    p_conn    in            cdb_connection,
    p_res     in out nocopy cdb_utl.t_container) is
    v_res    cdb_utl.t_container;
    a_data   cdb_utl.tab_container;
  begin
    cdb_sql.sql_to_doc_bulk(
      p_sql,
      p_binds,
      null,
      a_data);


    for i in a_data.first .. a_data.last loop
      cdb_utl.make_request_large(
        p_conn.get_uri(),
        'POST',
        p_conn.db_name || '/_bulk_docs',
        a_data(i),
        v_res);
      p_res.content := p_res.content || v_res.content;
    end loop;
  end send_bulk_docs;

  procedure bind_json(l_cur number, bindvar json) as
    keylist   json_list := bindvar.get_keys();
  begin
    for i in 1 .. keylist.count loop
      if (bindvar.get(i).get_type = 'number') then
        dbms_sql.
         bind_variable(
          l_cur,
          ':' || keylist.get(i).get_string,
          bindvar.get(i).get_number);
      elsif (bindvar.get(i).get_type = 'array') then
        declare
          v_bind   dbms_sql.varchar2_table;
          v_arr    json_list := json_list(bindvar.get(i));
        begin
          for j in 1 .. v_arr.count loop
            v_bind(j) := v_arr.get(j).value_of;
          end loop;

          dbms_sql.bind_array(l_cur, ':' || keylist.get(i).get_string, v_bind);
        end;
      else
        dbms_sql.
         bind_variable(
          l_cur,
          ':' || keylist.get(i).get_string,
          bindvar.get(i).value_of());
      end if;
    end loop;
  end bind_json;

  function executeList(stmt varchar2, bindvar json, cur_num number)
    return t_doc_list as
    l_cur        number;
    l_dtbl       dbms_sql.desc_tab;
    l_cnt        number;
    l_status     number;
    l_val        varchar2(4000);
    outer_list   t_doc_list;
    inner_obj    cdb_document;
    conv         number;
    read_date    date;
    read_clob    clob;
    read_blob    blob;
    col_type     number;
    v_count      number;
  begin
    if (cur_num is not null) then
      l_cur := cur_num;
    else
      l_cur := dbms_sql.open_cursor;
      dbms_sql.parse(l_cur, stmt, dbms_sql.native);

      if (bindvar is not null) then
        bind_json(l_cur, bindvar);
      end if;
    end if;

    dbms_sql.describe_columns(l_cur, l_cnt, l_dtbl);

    for i in 1 .. l_cnt loop
      col_type := l_dtbl(i).col_type;

      --dbms_output.put_line(col_type);
      if (col_type = 12) then
        dbms_sql.define_column(l_cur, i, read_date);
      elsif (col_type = 112) then
        dbms_sql.define_column(l_cur, i, read_clob);
      elsif (col_type = 113) then
        dbms_sql.define_column(l_cur, i, read_blob);
      elsif (col_type in (1, 2, 96)) then
        dbms_sql.define_column(
          l_cur,
          i,
          l_val,
          4000);
      end if;
    end loop;

    if (cur_num is null) then
      l_status := dbms_sql.execute(l_cur);
    end if;

    v_count := 0;

    --loop through rows
    while (dbms_sql.fetch_rows(l_cur) > 0) loop
      v_count := v_count + 1;
      inner_obj := cdb_document();                           --init for each row

      --loop through columns
      for i in 1 .. l_cnt loop
        case true
          --handling string types
          when l_dtbl(i).col_type in (1, 96) then                    -- varchar2
            dbms_sql.column_value(l_cur, i, l_val);

            if (l_val is null) then
              if (null_as_empty_string) then
                inner_obj.put(lower(l_dtbl(i).col_name), ''); --treatet as emptystring?
              else
                inner_obj.put(lower(l_dtbl(i).col_name), json_value.makenull); --null
              end if;
            else
              inner_obj.put(lower(l_dtbl(i).col_name), json_value(l_val)); --null
            end if;
          --dbms_output.put_line(lower(l_dtbl(i).col_name)||' --> '||l_val||'varchar2' ||l_dtbl(i).col_type);
          --handling number types
          when l_dtbl(i).col_type = 2 then                             -- number
            dbms_sql.column_value(l_cur, i, l_val);
            conv := l_val;
            inner_obj.put(lower(l_dtbl(i).col_name), conv);
          -- dbms_output.put_line(lower(l_dtbl(i).col_name)||' --> '||l_val||'number ' ||l_dtbl(i).col_type);
          when l_dtbl(i).col_type = 12 then                              -- date
            if (include_dates) then
              dbms_sql.column_value(l_cur, i, read_date);
              inner_obj.
               put(
                lower(l_dtbl(i).col_name),
                json_ext.to_json_value(read_date));
            end if;
          --dbms_output.put_line(lower(l_dtbl(i).col_name)||' --> '||l_val||'date ' ||l_dtbl(i).col_type);
          when l_dtbl(i).col_type = 112 then                              --clob
            if (include_clobs) then
              dbms_sql.column_value(l_cur, i, read_clob);
              inner_obj.put(lower(l_dtbl(i).col_name), json_value(read_clob));
            end if;
          when l_dtbl(i).col_type = 113 then                              --blob
            if (include_blobs) then
              dbms_sql.column_value(l_cur, i, read_blob);

              if (dbms_lob.getlength(read_blob) > 0) then
                inner_obj.
                 put(lower(l_dtbl(i).col_name), json_ext.encode(read_blob));
              else
                inner_obj.put(lower(l_dtbl(i).col_name), json_value.makenull);
              end if;
            end if;
          else
            null;                                          --discard other types
        end case;
      end loop;

      outer_list(v_count) := inner_obj;
    end loop;

    dbms_sql.close_cursor(l_cur);
    return outer_list;
  end executeList;

  function jj(p_col in varchar2, p_val in varchar2 := null)
    return varchar2 is
  begin
    if p_val is null then
      if (null_as_empty_string) then
        return '"' || lower(p_col) || '":"",';
      else
        return '"' || lower(p_col) || '":null,';
      end if;
    else
      return '"' || lower(p_col) || '":"' || p_val || '",';
    end if;
  end jj;

  function jj(p_col in varchar2, p_val in clob := null)
    return varchar2 is
  begin
    if p_val is null then
      if (null_as_empty_string) then
        return '"' || lower(p_col) || '":"",';
      else
        return '"' || lower(p_col) || '":null,';
      end if;
    else
      return '"' || lower(p_col) || '":"' || p_val || '",';
    end if;
  end jj;

  function jj(p_col in varchar2, p_val in number)
    return varchar2 is
  begin
    if p_val is null then
      if (null_as_empty_string) then
        return '"' || lower(p_col) || '":"",';
      else
        return '"' || lower(p_col) || '":null,';
      end if;
    else
      return '"' || lower(p_col) || '":' || p_val || ',';
    end if;
  end jj;

  function jj(p_col in varchar2, p_val in date)
    return varchar2 is
  begin
    if p_val is null then
      if (null_as_empty_string) then
        return '"' || lower(p_col) || '":"",';
      else
        return '"' || lower(p_col) || '":null,';
      end if;
    else
      return    '"'
             || lower(p_col)
             || '":"'
             || to_char(p_val, 'YYYY.MM.DD hh24:mi:ss')
             || '",';
    end if;
  end jj;

  procedure sql_to_doc_bulk(
    stmt                    varchar2,
    bindvar                 json default null,
    cur_num                 number default null,
    p_data    in out nocopy cdb_utl.tab_container) is
    l_cur       number;
    l_dtbl      dbms_sql.desc_tab;
    l_cnt       number;
    l_status    number;
    l_val       varchar2(4000);
    v_row       cdb_utl.t_container;
    v_data      cdb_utl.t_container;
    conv        number;
    read_date   date;
    read_clob   clob;
    read_blob   blob;
    col_type    number;
    v_count     number;
    v_s2        number := 0;
  begin
    if (cur_num is not null) then
      l_cur := cur_num;
    else
      l_cur := dbms_sql.open_cursor;
      dbms_sql.parse(l_cur, stmt, dbms_sql.native);

      if (bindvar is not null) then
        bind_json(l_cur, bindvar);
      end if;
    end if;

    dbms_sql.describe_columns(l_cur, l_cnt, l_dtbl);

    for i in 1 .. l_cnt loop
      col_type := l_dtbl(i).col_type;

      if (col_type = 12) then
        dbms_sql.define_column(l_cur, i, read_date);
      elsif (col_type = 112) then
        dbms_sql.define_column(l_cur, i, read_clob);
      elsif (col_type = 113) then
        dbms_sql.define_column(l_cur, i, read_blob);
      elsif (col_type in (1, 2, 96)) then
        dbms_sql.define_column(
          l_cur,
          i,
          l_val,
          4000);
      end if;
    end loop;

    if (cur_num is null) then
      l_status := dbms_sql.execute(l_cur);
    end if;

    v_count := 0;

    --loop through rows
    while (dbms_sql.fetch_rows(l_cur) > 0) loop
      v_count := v_count + 1;
      v_row.content := '{';                                  --init for each row

      --loop through columns
      for i in 1 .. l_cnt loop
        case true
          --handling string types
          when l_dtbl(i).col_type in (1, 96) then                    -- varchar2
            dbms_sql.column_value(l_cur, i, l_val);

            v_row.content := v_row.content || jj(l_dtbl(i).col_name, l_val);
          --handling number types
          when l_dtbl(i).col_type = 2 then                             -- number
            dbms_sql.column_value(l_cur, i, l_val);
            conv := l_val;
            v_row.content := v_row.content || jj(l_dtbl(i).col_name, conv);
          when l_dtbl(i).col_type = 12 then                              -- date
            if (include_dates) then
              dbms_sql.column_value(l_cur, i, read_date);
              v_row.content :=
                v_row.content || jj(l_dtbl(i).col_name, read_date);
            end if;
          when l_dtbl(i).col_type = 112 then                              --clob
            if (include_clobs) then
              dbms_sql.column_value(l_cur, i, read_clob);
              v_row.content := v_row.content || jj(l_dtbl(i).col_name, l_val);
            end if;
          else
            null;
        end case;
      end loop;

      v_row.content := rtrim(v_row.content, ',');
      v_row.content := concat(v_row.content, '}');

      if v_count < 1000 then
        v_data.content := v_data.content || v_row.content || ',';
      else
        v_data.content := concat(to_clob('{"docs":['), v_data.content);
        v_data.content := concat(v_data.content, v_row.content);
        v_data.content := concat(v_data.content, to_clob(']}'));
        v_s2 := v_s2 + 1;
        p_data(v_s2) := v_data;
        v_count := 0;
        v_data.content := null;
      end if;
    end loop;

    if v_data.content is not null then
      v_data.content := concat(to_clob('{"docs":['), v_data.content);
      v_data.content := rtrim(v_data.content, ',');
      v_data.content := concat(v_data.content, to_clob(']}'));
      p_data(v_s2 + 1) := v_data;
    end if;

    v_data.content := null;

    dbms_sql.close_cursor(l_cur);
  end sql_to_doc_bulk;
end cdb_sql;
/