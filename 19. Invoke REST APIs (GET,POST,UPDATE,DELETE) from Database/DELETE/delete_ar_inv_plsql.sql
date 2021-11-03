DECLARE
  l_clob                    CLOB;
  l_result                  VARCHAR2(32767);
  l_CustomerTransactionId   NUMBER := 300000224821099; -- trx_num 55772
  gc_url                    VARCHAR2(2000)  :=  'https://ucf6-zvju-fa-ext.oracledemos.com/fscmRestApi/resources/11.13.18.05/receivablesInvoices/'||l_CustomerTransactionId;
  gc_username               VARCHAR2(100)   := 'hcm_impl1';
  gc_password               VARCHAR2(100)   := 'Ehm84555';

BEGIN
  
  apex_web_service.g_request_headers(1).name := 'Content-Type';
  apex_web_service.g_request_headers(1).value := 'application/json';
  -- submit delete operation
  l_clob:= APEX_WEB_SERVICE.make_rest_request(
    p_url         => gc_url,
    p_http_method => 'DELETE',
    p_username    => gc_username,
    p_password    => gc_password 
  );

  DBMS_OUTPUT.put_line('l_clob=' || l_clob);

EXCEPTION
  WHEN OTHERS
  THEN
    dbms_output.put_line('Error here:'||substr(sqlerrm,1,200));
END;