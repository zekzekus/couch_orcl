CREATE OR REPLACE procedure ZEKUS.cdb_test_sql is
  conn    cdb_connection;
  dlist   cdb_sql.t_doc_list;
begin
  --utl_http.set_proxy('zekeriya.koc:zekeriya@10.80.1.161:8080', '10.81.3.221');
  -- static methods to create a test database
  --cdb_connection.
  --delete_db('http://admin:admin@zekzekus.iriscouch.com/', 'orcl001');
  --cdb_connection.
  --create_db('http://admin:admin@zekzekus.iriscouch.com/', 'orcl001');

  -- create connection to a specific database
  conn :=
    cdb_connection(
      host       => '10.81.2.100',
      port       => 5984,
      db_name    => 'dbmerkez',
      username   => 'admin',
      password   => 'admin');
  conn.print();

  dlist :=
    cdb_sql.executeList(
      'SELECT A.MGB00_BARCODE AS BARKOD,
       A.MGB00_ITEM_KODU AS ITEM_KODU,
       A.MGB00_BEDEN AS BEDEN,
       B.KDV_ORANI,
       B.ITEM_ADI,
       B.MARKA_KODU,
       B.MARKA_ADI,
       B.URUN_KODU,
       B.URUN_ADI,
       B.YIL,
       B.SEZON,
       B.MODEL,
       B.PSF,
       B.PSF_IND
  FROM MGB00@mrkz A,
       MG_ITEM@DBAYKF B
WHERE A.MGB00_ITEM_KODU        = B.ITEM_KODU
   --AND C.MGS99_MEVCUT_MIKTAR    <> 0
   --AND B.MGM00_MAGAZA_KODU      = ''7517''
   AND B.YIL              IN (''2012'')
   AND B.SEZON            IN (''KIŞ'')
');

  for i in dlist.first .. dlist.last loop
    dlist(i).conn := conn;
    dlist(i).set_id(cdb_utl.get_uuid());
    dlist(i).put('type', 'barkod');
    dlist(i).save();
  end loop; 
  
end;
/
