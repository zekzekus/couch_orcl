CREATE OR REPLACE procedure ZEKUS.test1 as
  v_data   cdb_utl.t_container;
  v_res    cdb_utl.t_container;

  type t_data is table of cdb_utl.t_container
                   index by binary_integer;

  cursor c_barkod is
    SELECT    '{"_id":"'
           || A.MGB00_BARCODE
           ||'","barkod":'
           ||A.MGB00_BARCODE
           || ',"item_kodu":"'
           || A.MGB00_ITEM_KODU
           || '","beden":"'
           || A.MGB00_BEDEN
           || '","kdv_orani":'
           || B.KDV_ORANI
           || ',"item_adi":"'
           || B.ITEM_ADI
           || '","marka_kodu":"'
           || B.MARKA_KODU
           || '","marka_adi":"'
           || B.MARKA_ADI
           || '","urun_kodu":"'
           || B.URUN_KODU
           || '","urun_adi":"'
           || B.URUN_ADI
           || '","yil":"'
           || B.YIL
           || '","sezon":"'
           || B.SEZON
           || '","model":"'
           || B.MODEL
           || '","psf":'
           || nvl(B.PSF, 0)
           || ',"psf_ind":'
           || nvl(B.PSF_IND, 0)
           || ',"type": "barkod"}'
             field02
      FROM MGB00@mrkz A, MG_ITEM@DBAYKF B
     WHERE A.MGB00_ITEM_KODU = B.ITEM_KODU
       AND B.YIL IN ('2012')
       AND B.SEZON IN ('KIŞ');

  cursor c_magaza_item is
      select    '{"_id": "'
             || lpad(b.mgm00_magaza_kodu, 10, '0')
             || lpad(b.mgs01_item_kodu, 20, '0')
             || '",'
             || '"magaza_kodu":"'
             || b.mgm00_magaza_kodu
             || '","item_kodu":"'
             || b.mgs01_item_kodu
             || '","psf":'
             || nvl(
                  max(decode(d.mgf01_tipi, '1', nvl(d.mgf00_fiyat, 0), null)),
                  0)
             || ',"psf_ind":'
             || nvl(
                  max(decode(d.mgf01_tipi, '2', nvl(d.mgf00_fiyat, 0), null)),
                  0)
             || ', "type": "magaza_item"}'
               field02
        from mgs01@mrkz b, mgf00@mrkz d
       where b.mgm00_magaza_kodu = d.mgm00_magaza_kodu(+)
         and b.mgs01_item_kodu = d.mgs01_item_kodu(+)
         --AND C.MGS99_MEVCUT_MIKTAR    <> 0
         --AND B.MGM00_MAGAZA_KODU      = '7529'
         and b.mgs01_yil in ('2012')
         and b.mgs01_sezon in ('KIŞ')
    group by b.mgm00_magaza_kodu, b.mgs01_item_kodu;

  a_data   t_data;
  v_s      number := 0;
  v_s2     number := 0;
begin
  err.log(1, 'geldim--1');

  for r in c_magaza_item loop
    v_s := v_s + 1;

    if v_s < 1000 then
      v_data.content := v_data.content || r.field02 || ',';
    else
      v_data.content := concat(to_clob('{"docs":['), v_data.content);
      v_data.content := concat(v_data.content, to_clob(r.field02));
      v_data.content := concat(v_data.content, to_clob(']}'));
      v_s2 := v_s2 + 1;
      a_data(v_s2) := v_data;
      --insert into tmp_clob values (v_data.content);
      v_s := 0;
      v_data.content := null;
    end if;
  end loop;

  if v_data.content is not null then
    v_data.content := concat(to_clob('{"docs":['), v_data.content);
    v_data.content := rtrim(v_data.content, ',');
    v_data.content := concat(v_data.content, to_clob(']}'));
    a_data(v_s2 + 1) := v_data;
  end if;

  v_data.content := null;
  err.log(1, 'geldim--2');

  for i in a_data.first .. a_data.last loop
    --v_data.content := i.clob_data;
    v_res.content := null;
    cdb_utl.make_request_large(
      'http://10.81.2.100:5984/',
      'POST',
      'dbmerkez/_bulk_docs',
      a_data(i),
      v_res);

    insert into tmp_clob
         values (a_data(i).content, v_res.content);

    commit;
  end loop;

  err.log(1, 'geldim--3');
end;
/
