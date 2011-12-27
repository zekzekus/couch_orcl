
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

declare begin
  begin execute immediate 'drop procedure cdb_test_sql'; exception when others then null; end;
  begin execute immediate 'drop procedure cdb_test'; exception when others then null; end;
  begin execute immediate 'drop package cdb_sql'; exception when others then null; end;
  begin execute immediate 'drop type cdb_document'; exception when others then null; end;
  begin execute immediate 'drop type cdb_connection'; exception when others then null; end;
  begin execute immediate 'drop package cdb_utl'; exception when others then null; end;
end;
/
