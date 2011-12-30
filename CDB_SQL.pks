CREATE OR REPLACE package cdb_sql as
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

  subtype v2_max is varchar2(32767);

  type t_doc_list is table of cdb_document
                       index by pls_integer;

  type g_qry_rec is record(
    col_name           varchar2(32):= '',
    col_value          nvarchar2(4000):= '',
    col_value_number   number:= null,
    col_value_date     date:= null);

  type g_qry_tab is table of g_qry_rec
                      index by binary_integer;

  null_as_empty_string   boolean not null := true;                    --varchar2
  include_dates          boolean not null := true;                        --date
  include_clobs          boolean not null := true;
  include_blobs          boolean not null := false;

  /* list with objects */
  function executeList(
    stmt       varchar2,
    bindvar    json default null,
    cur_num    number default null)
    return t_doc_list;
end cdb_sql;
/