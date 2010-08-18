CREATE OR REPLACE package body ZEKUS.cdb_utl as
  procedure p(p_msg in varchar2) is
  begin
    dbms_output.put_line(p_msg);
  end p;
  
  function make_request(
    p_uri           varchar2,
    p_method        varchar2,
    p_url           varchar := null,
    p_body          varchar2 := null)
    return varchar2 is
    v_req          utl_http.req;
    v_res          utl_http.resp;
    v_val          varchar2(32767);
  begin
    v_req       := utl_http.begin_request(p_uri || p_url, p_method);
    utl_http.set_body_charset(v_req, 'UTF-8');
    utl_http.set_header(v_req, 'User-Agent', 'Mozilla/4.0');
    utl_http.set_header(v_req, 'Content-Type', 'application/json');
    utl_http.set_header(v_req, 'Content-Length', length(p_body));
    utl_http.write_text(v_req, p_body);
    v_res       := utl_http.get_response(v_req);
    utl_http.read_text(v_res, v_val);
    utl_http.end_response(v_res);

    return v_val;
  exception
    when utl_http.end_of_body then
      utl_http.end_response(v_res);
    when others then
      utl_http.end_response(v_res);
      dbms_output.put_line(sqlerrm);
  end make_request;
  
  function info(p_uri varchar2) return json is
  begin
    return json_parser.parser(make_request(p_uri, 'GET'));
  end info;
end cdb_utl;
/
