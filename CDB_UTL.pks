CREATE OR REPLACE package ZEKUS.cdb_utl as
  function make_request(
    p_uri           varchar2,
    p_method        varchar2,
    p_url           varchar := null,
    p_body          varchar2 := null)
    return varchar2;
    
  function info(p_uri varchar2) return json;
end cdb_utl;
/
