CREATE OR REPLACE package cdb_utl as
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

  function make_request(
    p_uri           varchar2,
    p_method        varchar2,
    p_url           varchar := null,
    p_body          varchar2 := null)
    return varchar2;
    
  function server_info(p_uri varchar2) return json;
  
  function db_info(p_uri varchar2, p_db varchar2) return json;
  
  function get_uuid return varchar2;
  
  procedure p(p_msg in varchar2); 
end cdb_utl;
/
