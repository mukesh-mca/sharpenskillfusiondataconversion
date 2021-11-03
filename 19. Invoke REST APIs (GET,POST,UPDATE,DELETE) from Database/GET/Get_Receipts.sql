DECLARE
  l_clob    CLOB;
  l_result  VARCHAR2(32767);
BEGIN

  -- Get the XML response from the web service.
  l_clob:= APEX_WEB_SERVICE.make_rest_request(
    p_url         => 'https://ucf6-zvju-fa-ext.oracledemos.com/fscmRestApi/resources/11.13.18.05/standardReceipts',
    p_http_method => 'GET',
    p_username    => 'hcm_impl1',
    p_password    => 'Ehm84555' ,
    p_parm_name   => APEX_UTIL.string_to_table('q:onlyData:fields'),
    p_parm_value  => APEX_UTIL.string_to_table('ReceiptNumber='||267708||':'||'true'||':'||'ReceiptNumber,ReceiptDate')
  );

  -- Display the whole document returned.
  --DBMS_OUTPUT.put_line('l_clob=' || l_clob);

  SELECT rcpt_num 
    INTO l_result
    FROM JSON_TABLE(l_clob,'$' COLUMNS 
                           NESTED PATH '$.items[*]' COLUMNS (
                              RCPT_NUM VARCHAR2(30) PATH '$.ReceiptNumber'
                           ));
  DBMS_OUTPUT.put_line('l_result=' || l_result);
END;