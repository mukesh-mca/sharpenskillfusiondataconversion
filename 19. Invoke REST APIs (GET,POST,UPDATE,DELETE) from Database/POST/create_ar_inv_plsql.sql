DECLARE
  l_clob    CLOB;
  l_result  VARCHAR2(32767);
  gc_url                    VARCHAR2(2000)  := 'https://ucf6-zvju-fa-ext.oracledemos.com/fscmRestApi/resources/11.13.18.05/receivablesInvoices';
  gc_username               VARCHAR2(100)   := 'hcm_impl1';
  gc_password               VARCHAR2(100)   := 'Ehm84555';
  -- JSON Request Payload
  gc_ar_inv_payload     	CLOB := '{
    "BillToCustomerNumber": "16080",
	"BillToSite": "San Jose",
    "BusinessUnit": "US1 Business Unit",
    "InvoiceCurrencyCode": "USD",
    "PaymentTerms": "Net 30",
    "TransactionDate": "2020-10-10",
    "TransactionSource": "Manual",
    "ShipToCustomerNumber": "16080",
    "ShipToSite": "1032",
    "TransactionType": "Invoice",
    "InvoiceStatus": "Complete",
    "receivablesInvoiceLines": [
       {
          "Description": "Item",
          "LineNumber": 1,
          "Quantity": 102,
          "UnitSellingPrice": 100,
          "receivablesInvoiceLineTaxLines": [
             {
                "TaxAmount": 663,
				"TaxRate": 6.5,
				"TaxRateCode": "STD",
				"TaxRegimeCode": "US SALES AND USE TAX"
             }
          ]
       },
       {
          "Description": "Item",
          "LineNumber": 2,
          "Quantity": 10,
          "UnitSellingPrice": 100,
          "receivablesInvoiceLineTaxLines": [
             {
                "TaxAmount": 65,
				"TaxRate": 6.5,
				"TaxRateCode": "STD",
				"TaxRegimeCode": "US SALES AND USE TAX"
             }
          ]
       }
    ]
 }';
BEGIN
  
  APEX_WEB_SERVICE.G_REQUEST_HEADERS(1).NAME := 'Content-Type';
  APEX_WEB_SERVICE.G_REQUEST_HEADERS(1).VALUE := 'application/json';
  -- Get the response from the web service.
  l_clob:= APEX_WEB_SERVICE.MAKE_REST_REQUEST(
    p_url         => gc_url,
    p_http_method => 'POST',
    p_username    => gc_username,
    p_password    => gc_password ,
    p_body        => gc_ar_inv_payload
  );

  --DBMS_OUTPUT.put_line('l_clob=' || l_clob);
  --Display transaction number using JSON_TABLE
  SELECT transaction_number 
    INTO l_result
    FROM JSON_TABLE(l_clob,'$' COLUMNS  (
                              transaction_number VARCHAR2(30) PATH '$.TransactionNumber'
                           ));
  DBMS_OUTPUT.PUT_LINE('l_result=' || l_result);

EXCEPTION
  WHEN OTHERS
  THEN
    DBMS_OUTPUT.PUT_LINE('Error here:'||SUBSTR(SQLERRM,1,200));
END;