DECLARE
  l_xml                 XMLTYPE;
  l_result              CLOB;
  lc_action             VARCHAR2(30)    := 'runReport';
  gc_url                VARCHAR2(2000)  := 'https://ucf6-zxrj-fa-ext.oracledemos.com/xmlpserver/services/ExternalReportWSSService';
  gc_version            NUMBER          := 1.2;
  gc_username           VARCHAR2(100)   := 'Raja.Dutta';
  gc_password           VARCHAR2(100)   := 'Welcome@123';
  gc_attributeFormat    VARCHAR2(50)    := 'xml';
  gc_gl_periods_payload CLOB := '<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:pub="http://xmlns.oracle.com/oxp/service/PublicReportService">
	   <soap:Header/>
	   <soap:Body>
		  <pub:runReport>
			 <pub:reportRequest>
			   <pub:attributeFormat>'||gc_attributeFormat||'</pub:attributeFormat>
               <pub:parameterNameValues>
                  <pub:item>
                     <pub:name>p_das_name</pub:name>
                     <pub:values>
                        <pub:item>US Primary Ledger</pub:item>
                     </pub:values>
                  </pub:item>
                  <pub:item>
                     <pub:name>p_ledger_name</pub:name>
                     <pub:values>
                        <pub:item>US Primary Ledger</pub:item>
                     </pub:values>
                  </pub:item>
            </pub:parameterNameValues>
				<pub:reportAbsolutePath>/Custom/Financials/GL_DAS_Ledger_Report.xdo</pub:reportAbsolutePath>
				<pub:sizeOfDataChunkDownload>-1</pub:sizeOfDataChunkDownload>
				</pub:reportRequest>
				 </pub:runReport>
	   </soap:Body>
	</soap:Envelope>';
  -- Base64 decoding related variables
  l_blob                    BLOB;
  l_raw                     RAW(32767);
  l_amt                     NUMBER := 7700;
  l_offset                  NUMBER := 1;
  l_temp                    VARCHAR2(32767);
  
  -- BLOB to XML CLOB conversion related variables
  l_clob                    CLOB;
  lc_xml_clob               CLOB;
  lc_varchar                VARCHAR2(32767);
  ln_start                  PLS_INTEGER := 1;
  ln_buffer                 PLS_INTEGER := 32767;
BEGIN
  DBMS_OUTPUT.put_line('SOAP Request Message Prepared');
  -- Invoke the Report Service
  l_xml := APEX_WEB_SERVICE.make_request(
             p_url       => gc_url,
             p_version   => gc_version,
             p_action    => lc_action,
			 p_envelope  => gc_gl_periods_payload,
             p_username  => gc_username,
             p_password  => gc_password );
  
  -- Display the whole SOAP document returned
  -- if report returns smaller data set
  --DBMS_OUTPUT.put_line('l_xml=========>' || l_xml.getClobVal());
  DBMS_OUTPUT.put_line('Report Service Invoked');
  
  -- Parse SOAP XML Response returned by the Report Service
  l_result := APEX_WEB_SERVICE.parse_xml_clob(
    p_xml   => l_xml,
    p_xpath => '//reportBytes/text()',
    p_ns    => 'xmlns="http://xmlns.oracle.com/oxp/service/PublicReportService"'
  );

  --DBMS_OUTPUT.put_line('l_result==========>' || l_result);
  DBMS_OUTPUT.put_line('SOAP Response Parsed');
  
  -- Decode Base64 encoding to File BLOB
  dbms_lob.createtemporary(l_blob, true);
  FOR i in 1 .. ceil(dbms_lob.getlength(l_result) / l_amt)
  LOOP
    dbms_lob.read(l_result, l_amt, l_offset, l_temp);    
    l_raw := utl_encode.base64_decode(utl_raw.cast_to_raw(l_temp));
    dbms_lob.append(l_blob, to_blob(l_raw));
    l_offset := l_offset + l_amt;
  END LOOP;
  DBMS_OUTPUT.put_line('Base64 Encoding Decoded');
  
  -- BLOB to XML CLOB Conversion
  dbms_lob.createtemporary(l_clob, true);
  FOR i IN 1..ceil(dbms_lob.getlength(l_blob) / ln_buffer) LOOP
    lc_varchar := utl_raw.cast_to_varchar2(dbms_lob.substr(l_blob, ln_buffer, ln_start));

    dbms_lob.writeappend(l_clob, length(lc_varchar), lc_varchar);
    ln_start := ln_start + ln_buffer;
  END LOOP;

  l_xml := xmltype.createxml(l_clob);
  lc_xml_clob := l_xml.getclobval();
  DBMS_OUTPUT.put_line('XML CLOB Generated');
  
  -- Iterate through XML Table rows and merge data into the DB Table
  FOR r IN (
      SELECT extractvalue(VALUE(p), '/G_1/ACCESS_SET_ID/text()') AS ACCESS_SET_ID,
             extractvalue(VALUE(p), '/G_1/LEDGER_ID/text()') AS LEDGER_ID,
             extractvalue(VALUE(p), '/G_1/ACCESS_SET_NAME/text()') AS ACCESS_SET_NAME,
             extractvalue(VALUE(p), '/G_1/LEDGER_NAME/text()') AS LEDGER_NAME
        FROM TABLE ( xmlsequence(EXTRACT(xmltype(lc_xml_clob), '/DATA_DS/G_1')) ) p
  )
  LOOP
	-- Merge if match found update the status and last update date, if not found then insert
    MERGE INTO xx_gl_ledger_das_lookup XGLDL 
	     USING (SELECT 1 
	              FROM DUAL) d 
			ON (XGLDL.das_name = r.access_set_name 
			    AND XGLDL.ledger_name = r.ledger_name)
          WHEN MATCHED
		  THEN UPDATE SET   XGLDL.ledger_id = r.ledger_id
			              , XGLDL.das_id = r.access_set_id
						  , XGLDL.last_update_date = SYSDATE
          WHEN NOT MATCHED 
		  THEN INSERT (  ledger_id
                       , ledger_name
                       , das_id
					   , das_name
                       , last_update_date) 
			   VALUES (  r.ledger_id
                       , r.ledger_name
                       , r.access_set_id
					   , r.access_set_name 
                       , SYSDATE);
  END LOOP;
  COMMIT;
  DBMS_OUTPUT.put_line('Data Inserted/Updated');
  
  -- Free Temporary memory
  dbms_lob.freetemporary(l_clob);
  dbms_lob.freetemporary(l_blob);
  
EXCEPTION
  WHEN OTHERS
  THEN
    dbms_output.put_line('Error here:'||substr(sqlerrm,1,200));
END;