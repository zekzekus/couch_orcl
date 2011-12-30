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
                inner_obj.put(lower(l_dtbl(i).col_name), json_value.makenull);   --null
              end if;
            else
              inner_obj.put(lower(l_dtbl(i).col_name), json_value(l_val));       --null
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
               put(lower(l_dtbl(i).col_name), json_ext.to_json_value(read_date));
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
                inner_obj.put(lower(l_dtbl(i).col_name), json_ext.encode(read_blob));
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
end cdb_sql;
/