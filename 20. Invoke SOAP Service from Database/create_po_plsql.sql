DECLARE
  -- Purchase Order SOAP service invocation related variables
  l_xml                     XMLTYPE;
  l_result                  CLOB;
  lc_action                 VARCHAR2(30)    := 'createPurchaseOrder';
  gc_url                    VARCHAR2(2000)  := 'https://ucf6-zvju-fa-ext.oracledemos.com/fscmService/PurchaseOrderServiceV2';
  gc_version                NUMBER          := 2;
  gc_username               VARCHAR2(100)   := 'hcm_impl1';
  gc_password               VARCHAR2(100)   := 'Ehm84555';
  -- SOAP Request Payload
  gc_po_payload     		CLOB := '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
    <soap:Body>
        <ns1:createPurchaseOrder xmlns:ns1="http://xmlns.oracle.com/apps/prc/po/editDocument/purchaseOrderServiceV2/types/">
            <ns1:createOrderEntry xmlns:ns2="http://xmlns.oracle.com/apps/prc/po/editDocument/purchaseOrderServiceV2/">
                <ns2:DocumentStyle>Purchase Order</ns2:DocumentStyle>
                <ns2:ProcurementBusinessUnit>US1 Business Unit</ns2:ProcurementBusinessUnit>
                <ns2:RequisitioningBusinessUnit>US1 Business Unit</ns2:RequisitioningBusinessUnit>
                <ns2:SoldToLegalEntity>US1 Legal Entity NC</ns2:SoldToLegalEntity>
                <ns2:BuyerName>Gee, May</ns2:BuyerName>
                <ns2:Supplier>EIP Inc</ns2:Supplier>
                <ns2:SupplierSiteCode>EIP US1</ns2:SupplierSiteCode>
                <ns2:SupplierContactName>Kim, John</ns2:SupplierContactName>
                <ns2:DocumentDescription>Create using name attributes</ns2:DocumentDescription>
                <ns2:PurchaseOrderEntryLine>
                    <ns2:LineNumber>1</ns2:LineNumber>
                    <ns2:LineType>Goods</ns2:LineType>
                    <!--<ns2:ItemNumber>CM31556</ns2:ItemNumber>-->
					<ns2:ItemDescription>Test PO item</ns2:ItemDescription>
                    <ns2:CategoryName>Miscellaneous</ns2:CategoryName>
					<ns2:Price>11</ns2:Price>
                    <ns2:UnitOfMeasure>Ea</ns2:UnitOfMeasure>
                    <ns2:Quantity>10</ns2:Quantity>
                    <ns2:PurchaseOrderEntrySchedule>
                        <ns2:ShipToLocationCode>Seattle</ns2:ShipToLocationCode>
						<ns2:ShipToOrganizationCode>001</ns2:ShipToOrganizationCode>
                        <ns2:PurchaseOrderEntryDistribution>
							<ns2:POChargeAccount>101.10.63120.251.000.000</ns2:POChargeAccount>
                        </ns2:PurchaseOrderEntryDistribution>
                    </ns2:PurchaseOrderEntrySchedule>
                </ns2:PurchaseOrderEntryLine>
            </ns1:createOrderEntry>
        </ns1:createPurchaseOrder>
    </soap:Body>
</soap:Envelope>';

BEGIN
  DBMS_OUTPUT.put_line('SOAP Request Message Prepared');
  -- Invoke the Purchase Order SOAP Service
  l_xml := APEX_WEB_SERVICE.make_request(
             p_url       => gc_url,
             p_version   => gc_version,
             p_action    => lc_action,
			 p_envelope  => gc_po_payload,
             p_username  => gc_username,
             p_password  => gc_password );

  --DBMS_OUTPUT.put_line('l_xml=========>' || l_xml.getClobVal());
  -- Parse the xml response
  l_result := APEX_WEB_SERVICE.parse_xml_clob(
    p_xml   => l_xml,
    p_xpath => '//OrderNumber/text()',
    p_ns    => 'xmlns="http://xmlns.oracle.com/apps/prc/po/editDocument/purchaseOrderServiceV2/"'
  );

  DBMS_OUTPUT.put_line('Purchase Order Number ==========>' || l_result);
			 
EXCEPTION
  WHEN OTHERS
  THEN
    dbms_output.put_line('Error here:'||substr(sqlerrm,1,200));
END;