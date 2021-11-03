DECLARE
  l_clob                    CLOB;
  l_result                  VARCHAR2(32767);
  l_CustomerTransactionId   NUMBER := 300000224661149; -- trx_number 56766 ra_customer_trx_all trx_number
  gc_url                    VARCHAR2(2000)  :=  'https://ucf6-zvju-fa-ext.oracledemos.com/fscmRestApi/resources/11.13.18.05/receivablesInvoices/'||l_CustomerTransactionId;
  gc_username               VARCHAR2(100)   := 'hcm_impl1';
  gc_password               VARCHAR2(100)   := 'Ehm84555';
  -- JSON Request Payload
  gc_acct_date_payload     	CLOB := '{
    "Comments" : "test update from plsql"
 }';
BEGIN
  
  apex_web_service.g_request_headers(1).name := 'Content-Type';
  apex_web_service.g_request_headers(1).value := 'application/json';
  -- Get the response from the web service.
  l_clob:= APEX_WEB_SERVICE.make_rest_request(
    p_url         => gc_url,
    p_http_method => 'PATCH',
    p_username    => gc_username,
    p_password    => gc_password ,
    p_body        => gc_acct_date_payload
  );

  --DBMS_OUTPUT.put_line('l_clob=' || l_clob);

  SELECT transaction_number 
    INTO l_result
    FROM JSON_TABLE(l_clob,'$' COLUMNS  (
                              transaction_number VARCHAR2(30) PATH '$.TransactionNumber'
                           ));
  DBMS_OUTPUT.put_line('l_result=' || l_result);

EXCEPTION
  WHEN OTHERS
  THEN
    dbms_output.put_line('Error here:'||SUBSTR(SQLERRM,1,200));
END;