CREATE OR REPLACE package body cdb_sql as
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

  procedure sql_to_doc(
    p_type         in            varchar2,
    p_sql          in            varchar2,
    p_result       in out nocopy t_doc_list) as
    sc             integer;
    rp             integer;
    v_qry_col_count integer;
    v_qry_gender   dbms_sql.desc_tab;
    v_deg          v2_max;
    v_ii           integer;
    v_jj           integer;
    conv           number;
    read_date      date;

    v_doc          cdb_document;
  begin
    sc          := dbms_sql.open_cursor;
    dbms_sql.parse(sc, p_sql, dbms_sql.native);
    -- column spesifications
    dbms_sql.describe_columns(sc, v_qry_col_count, v_qry_gender);

    --
    for v_ii in 1 .. v_qry_col_count loop
      dbms_sql.define_column(
        sc,
        v_ii,
        v_qry_gender(v_ii).col_type,
        v_qry_gender(v_ii).col_max_len);
    end loop;

    rp          := dbms_sql.execute(sc);
    v_jj        := 0;

    loop
      if dbms_sql.fetch_rows(sc) > 0 then
        v_jj        := v_jj + 1;
        v_doc       := cdb_document();

        if p_type is not null then
          v_doc.put('type', p_type);
        end if;

        for v_ii in 1 .. v_qry_col_count loop
          case v_qry_gender(v_ii).col_type
            when 1 then
              dbms_sql.column_value(sc, v_ii, v_deg);

              if v_deg is null then
                v_doc.put(lower(v_qry_gender(v_ii).col_name), '');
              else
                declare
                  v              json_value;
                begin
                  v           := json_parser.parse_any('"' || v_deg || '"');
                  v_doc.put(lower(v_qry_gender(v_ii).col_name), v);       --null
                exception
                  when others then
                    v_doc.
                     put(
                      lower(v_qry_gender(v_ii).col_name),
                      json_value.makenull);                               --null
                end;
              end if;
            when 2 then
              dbms_sql.column_value(sc, v_ii, v_deg);
              conv        := v_deg;
              v_doc.put(lower(v_qry_gender(v_ii).col_name), conv);
            when 12 then
              dbms_sql.column_value(sc, v_ii, v_deg);
              read_date   := v_deg;
              v_doc.
               put(
                lower(v_qry_gender(v_ii).col_name),
                json_ext.to_json_value(read_date));
            else
              null;
          end case;
        end loop;

        p_result(v_jj) := v_doc;
      else
        exit;
      end if;
    end loop;

    dbms_sql.close_cursor(sc);
  end sql_to_doc;
end cdb_sql;
/