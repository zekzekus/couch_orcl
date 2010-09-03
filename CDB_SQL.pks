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

  procedure sql_to_doc(
    p_type         in            varchar2,
    p_sql          in            varchar2,
    p_result       in out nocopy t_doc_list);
end cdb_sql;
/