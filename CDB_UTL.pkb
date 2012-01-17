create or replace package body zekus.cdb_utl as
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

  procedure p(p_msg in varchar2) is
  begin
    dbms_output.put_line(p_msg);
  end p;

  function make_request(
    p_uri       varchar2,
    p_method    varchar2,
    p_url       varchar := null,
    p_body      varchar2 := ' ')
    return varchar2 is
    v_req   utl_http.req;
    v_res   utl_http.resp;
    v_val   varchar2(32767);
  begin
    v_req := utl_http.begin_request(p_uri || p_url, p_method);
    utl_http.set_body_charset(v_req, 'UTF-8');
    utl_http.set_header(v_req, 'User-Agent', 'Mozilla/4.0');
    utl_http.set_header(v_req, 'Content-Type', 'application/json');
    utl_http.set_header(v_req, 'Content-Length', length(p_body));
    utl_http.write_text(v_req, p_body);
    v_res := utl_http.get_response(v_req);

    begin
      utl_http.read_text(r => v_res, data => v_val);
    exception
      when utl_http.end_of_body then
        null;
    end;

    utl_http.end_response(v_res);

    return v_val;
  exception
    when utl_http.end_of_body then
      utl_http.end_response(v_res);
    when others then
      dbms_output.put_line(sqlerrm);
      utl_http.end_response(v_res);
      raise;
  end make_request;

  function make_request_large(
    p_uri       varchar2,
    p_method    varchar2,
    p_url       varchar := null,
    p_body      t_container)
    return t_container is
    v_req                  utl_http.req;
    v_res                  utl_http.resp;
    v_val                  varchar2(32767);
    v_clob_length          number;
    c_max_chunk   constant number := 32767;
    v_chunk_data           varchar2(32767);
    v_start                number := 1;
    v_return               t_container;
    v_body                 t_container;
  begin
    if p_body.content is null then
      v_body.content := ' ';
    else
      v_body.content := p_body.content;
    end if;

    v_clob_length := dbms_lob.getlength(v_body.content);
    v_req := utl_http.begin_request(p_uri || p_url, p_method);
    utl_http.set_transfer_timeout(6000);
    utl_http.set_transfer_timeout(v_req, 6000);
    utl_http.set_body_charset(v_req, 'UTF-8');
    utl_http.set_header(v_req, 'User-Agent', 'Mozilla/4.0');
    utl_http.
     set_header(v_req, 'Content-Type', 'application/json; charset=utf-8');
    utl_http.set_header(v_req, 'Connection', 'keep-alive');

    --if v_clob_length > c_max_chunk then
    utl_http.set_header(v_req, 'Transfer-Encoding', 'chunked');

    --else
    --utl_http.set_header(v_req, 'Content-Length', v_clob_length);
    --end if;

    --if v_clob_length <= c_max_chunk then
    --utl_http.write_text(v_req, v_body.content);
    --else
    while v_start < v_clob_length loop
      v_chunk_data := dbms_lob.substr(v_body.content, c_max_chunk, v_start);
      utl_http.write_text(v_req, v_chunk_data);
      v_start := v_start + c_max_chunk;
    end loop;

    --end if;
    v_res := utl_http.get_response(v_req);

    begin
      loop
        utl_http.read_text(v_res, v_val, c_max_chunk);
        v_return.content := v_return.content || v_val;
      end loop;
    exception
      when utl_http.end_of_body then
        utl_http.end_response(v_res);
    end;

    --utl_http.end_response(v_res);
    return v_return;
  exception
    when utl_http.end_of_body then
      utl_http.end_response(v_res);
    when others then
      dbms_output.put_line(sqlerrm);
      --utl_http.end_response(v_res);
      raise;
  end make_request_large;

  procedure make_request_large(
    p_uri                    varchar2,
    p_method                 varchar2,
    p_url                    varchar := null,
    p_body     in out nocopy t_container,
    p_result   in out nocopy t_container) is
    v_req                  utl_http.req;
    v_res                  utl_http.resp;
    v_val                  varchar2(32767);
    v_clob_length          number;
    c_max_chunk   constant number := 32767;
    v_chunk_data           varchar2(32767);
    v_start                number := 1;
  begin
    if p_body.content is null then
      p_body.content := ' ';
    end if;

    v_clob_length := dbms_lob.getlength(p_body.content);
    v_req := utl_http.begin_request(p_uri || p_url, p_method);
    utl_http.set_transfer_timeout(6000);
    utl_http.set_transfer_timeout(v_req, 6000);
    utl_http.set_body_charset(v_req, 'UTF-8');
    utl_http.set_header(v_req, 'User-Agent', 'Mozilla/4.0');
    utl_http.
     set_header(v_req, 'Content-Type', 'application/json; charset=utf-8');
    utl_http.set_header(v_req, 'Connection', 'keep-alive');

    utl_http.set_header(v_req, 'Transfer-Encoding', 'chunked');

    while v_start < v_clob_length loop
      v_chunk_data := dbms_lob.substr(p_body.content, c_max_chunk, v_start);
      utl_http.write_text(v_req, v_chunk_data);
      v_start := v_start + c_max_chunk;
    end loop;

    v_res := utl_http.get_response(v_req);

    begin
      loop
        utl_http.read_text(v_res, v_val, c_max_chunk);
        p_result.content := p_result.content || v_val;
      end loop;
    exception
      when utl_http.end_of_body then
        utl_http.end_response(v_res);
    end;
  exception
    when utl_http.end_of_body then
      utl_http.end_response(v_res);
    when others then
      dbms_output.put_line(sqlerrm);
      raise;
  end make_request_large;

  function server_info(p_uri varchar2)
    return json is
  begin
    return json_parser.parser(make_request(p_uri, 'GET'));
  end server_info;

  function get_uuid
    return varchar2 is
  begin
    return lower(sys_guid());
  end get_uuid;

  function db_info(p_uri varchar2, p_db varchar2)
    return json is
  begin
    return json_parser.parser(make_request(p_uri, 'GET', p_db));
  end db_info;

  function db_create(p_uri varchar2, p_name varchar2)
    return json as
  begin
    return json_parser.parser(make_request(p_uri, 'PUT', p_name));
  end db_create;

  function db_delete(p_uri varchar2, p_name varchar2)
    return json as
    v_dumm   varchar2(30000) := make_request(p_uri, 'DELETE', p_name);
  begin
    return json_parser.parser(v_dumm);
  end db_delete;  
end cdb_utl;
/