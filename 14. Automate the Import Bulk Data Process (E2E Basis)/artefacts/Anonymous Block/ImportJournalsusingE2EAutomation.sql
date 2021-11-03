DECLARE
  lc_ledger_name  VARCHAR2(100) := 'US Primary Ledger';
  ln_succ_rec_cnt NUMBER := 0;
  
  -- variable related dynamic SQL statement execution
  -- SQL Query with transformation rules on clean data
  lc_sql_text     CLOB := ' SELECT
    ''NEW'' status,
    (
        SELECT
            ledger_id
        FROM
            xx_gl_ledger_das_lookup
        WHERE
            ledger_name = ''US Primary Ledger''
    ) ledger_id,
    accounting_date,
    ''Spreadsheet'' user_je_source_name,
    ''Miscellaneous'' user_je_category_name,
    currency_code,
    date_created,
    ''A'' actual_flag,
    segment1,
    segment2,
    segment3,
    segment4,
    segment5,
    segment6,
    segment7,
    segment8,
    segment9,
    segment10,
    segment11,
    segment12,
    segment13,
    segment14,
    segment15,
    segment16,
    segment17,
    segment18,
    segment19,
    segment20,
    segment21,
    segment22,
    segment23,
    segment24,
    segment25,
    segment26,
    segment27,
    segment28,
    segment29,
    segment30,
    entered_dr,
    entered_cr,
    accounted_dr,
    accounted_cr,
    reference1,
    reference2,
    reference3,
    reference1   reference4,
    reference5,
    reference6,
    reference7,
    reference8,
    reference9,
    reference10,
    reference21,
    reference22,
    reference23,
    reference24,
    reference25,
    reference26,
    reference27,
    reference28,
    reference29,
    reference30,
    stat_amount,
    user_currency_conversion_type,
    currency_conversion_date,
    currency_conversion_rate,
    group_id,
    attribute_category,
    attribute1,
    attribute2,
    attribute3,
    attribute4,
    attribute5,
    attribute6,
    attribute7,
    attribute8,
    attribute9,
    attribute10,
    attribute11,
    attribute12,
    attribute13,
    attribute14,
    attribute15,
    attribute16,
    attribute17,
    attribute18,
    attribute19,
    attribute20,
    attribute_category3,
    average_journal_flag,
    originating_bal_seg_value,
    ledger_name,
    encumbrance_type_id,
    jgzz_recon_ref,
    period_name,
    reference18,
    reference19,
    reference20,
    attribute_date1,
    attribute_date2,
    attribute_date3,
    attribute_date4,
    attribute_date5,
    attribute_date6,
    attribute_date7,
    attribute_date8,
    attribute_date9,
    attribute_date10,
    attribute_number1,
    attribute_number2,
    attribute_number3,
    attribute_number4,
    attribute_number5,
    attribute_number6,
    attribute_number7,
    attribute_number8,
    attribute_number9,
    attribute_number10,
    global_attribute_category,
    global_attribute1,
    global_attribute2,
    global_attribute3,
    global_attribute4,
    global_attribute5,
    global_attribute6,
    global_attribute7,
    global_attribute8,
    global_attribute9,
    global_attribute10,
    global_attribute11,
    global_attribute12,
    global_attribute13,
    global_attribute14,
    global_attribute15,
    global_attribute16,
    global_attribute17,
    global_attribute18,
    global_attribute19,
    global_attribute20,
    global_attribute_date1,
    global_attribute_date2,
    global_attribute_date3,
    global_attribute_date4,
    global_attribute_date5,
    global_attribute_number1,
    global_attribute_number2,
    global_attribute_number3,
    global_attribute_number4,
    global_attribute_number5
FROM
    gl_interface_stg
WHERE
    1 = 1
    AND NOT EXISTS (
        SELECT
            1
        FROM
            xx_data_pre_vld_errors
        WHERE
            error_value1 = record_id
    )
    AND ledger_name = ''US Primary Ledger''';
  ln_cursor_id   NUMBER;	
  ln_exec_id     NUMBER;
  ln_col_count   INTEGER;
  desc_rec_tab   DBMS_SQL.DESC_TAB;
  lc_varchar_val VARCHAR2(4000);
  ln_num_val     NUMBER;
  ln_row_exists  NUMBER;
  ld_date_val    DATE;
  lc_data        CLOB;
  lc_dataset     CLOB;
  --
  -- Write CLOB to File Variables
  l_file      UTL_FILE.FILE_TYPE;
  l_buffer    VARCHAR2(32767);
  l_amount    BINARY_INTEGER := 32767;
  l_pos       INTEGER := 1;
  l_dir       VARCHAR2(100) := 'STAGE_DIR'; -- DBA Directory
  l_file_name VARCHAR2(150) := 'GlInterface.csv'; -- FBDI CSV File name
  --
  -- Generate ZIP variables
  lb_bfile          BFILE;
  lb_blob           BLOB;
  lb_zip            BLOB;
  ln_size           INTEGER;
  ln_dest_offset    INTEGER := 1;
  ln_src_offset     INTEGER := 1;
  lc_doc_title      VARCHAR2(100) := 'ImportJournal'||TO_CHAR(SYSDATE,'DDMMYYYYHHMISS');
  lc_zipfile_name   VARCHAR2(500) := lc_doc_title||'.zip';
  --
  -- Get Base64 encoding variable from ZIP
  lc_base64_zip    CLOB;
  l_step           PLS_INTEGER := 12000;
  --
  -- Properties Variables
  ln_group_id      NUMBER := :group_id;
  lc_gl_param_list VARCHAR2(1000);
  --
  -- Prepare SOAP Message variables
  gc_gl_journal_payload_begin CLOB          := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:typ="http://xmlns.oracle.com/apps/financials/commonModules/shared/model/erpIntegrationService/types/" xmlns:erp="http://xmlns.oracle.com/apps/financials/commonModules/shared/model/erpIntegrationService/">
  <soapenv:Body>
  <typ:importBulkData>';
  
  gc_gl_journal_payload_end   CLOB          := '</typ:importBulkData>
  </soapenv:Body>
  </soapenv:Envelope>';
  
  lc_soap_request        CLOB;
  gc_username            VARCHAR2(100)   := 'Raja.Tran';
  gc_password            VARCHAR2(100)   := 'Welcome@123';
  gc_doc_security_group  VARCHAR2(50)    := 'FAFusionImportExport';
  gc_zip_mimetype        VARCHAR2(10)    := 'zip';
  gc_dba_dir             VARCHAR2(100)   := 'STAGE_DIR';
  gc_gl_doc_account      VARCHAR2(50)    := 'fin$/generalLedger$/import$';
  gc_gl_job_name         VARCHAR2(500)   := 'oracle/apps/ess/financials/generalLedger/programs/common,JournalImportLauncher';
  gc_notify_code         VARCHAR2(5)     := '30';
  gc_gl_cb_url           VARCHAR2(1000)  := NULL;
  lc_job_options         VARCHAR2(1000)  := 'EnableEvent=Y,importOption=Y,purgeOption=Y,ExtractFileType!= NONE';
  --
  -- Invoke importBulkData Variables
  gc_erpint_url          VARCHAR2(2000)  := 'https://UCF6-zxnh-fa-ext.oracledemos.com/fscmService/ErpIntegrationService';
  gc_version_11          NUMBER          := 1.1;
  lc_action              VARCHAR2(30)    := 'importBulkData';
  lx_xml_response        XMLTYPE;
  lc_resp_clob           CLOB;
  lc_processid           VARCHAR2(20);
  --
  -- Get ESS Job Status related variables
  gc_essjob_status_payload_begin CLOB           := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:typ="http://xmlns.oracle.com/apps/financials/commonModules/shared/model/erpIntegrationService/types/">
   <soapenv:Header/>
   <soapenv:Body>
      <typ:getESSJobStatus>
         <typ:requestId>';
  gc_essjob_status_payload_end  CLOB  := '</typ:requestId>
      </typ:getESSJobStatus>
   </soapenv:Body>
  </soapenv:Envelope>';
  lc_essjobstat_action     VARCHAR2(30)    := 'getESSJobStatus';
  ln_timer_cnt             NUMBER := 0;
  lc_essjob_status_payload CLOB;
  lc_status                VARCHAR2(50);
  --
  -- XX_FIND_ESS_REQUESTID_REPORT Report related attributes
  gc_xml_attributeFormat        VARCHAR2(50)    := 'xml';
  gc_essjob_req_xdo             VARCHAR2(500)   := '/Custom/Financials/XX_FIND_ESS_REQUESTID_REPORT.xdo';
  gc_essjob_req_payload_begin   CLOB            := '<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:pub="http://xmlns.oracle.com/oxp/service/PublicReportService">
	   <soap:Header/>
	   <soap:Body>
		  <pub:runReport>
			 <pub:reportRequest>
			   <pub:attributeFormat>'||gc_xml_attributeFormat||'</pub:attributeFormat>
			   <pub:parameterNameValues>
                  <pub:item>
                     <pub:name>p_param_name</pub:name>
                     <pub:values>
                        <pub:item>submit.argument%attributeValue</pub:item>
                     </pub:values>
                  </pub:item>
                  <pub:item>
                     <pub:name>p_group_id</pub:name>
                     <pub:values>
                        <pub:item>';
  gc_essjob_req_payload_end       CLOB            := '</pub:item>
                     </pub:values>
                  </pub:item>
            </pub:parameterNameValues>
				<pub:reportAbsolutePath>'||gc_essjob_req_xdo||'</pub:reportAbsolutePath>
				<pub:sizeOfDataChunkDownload>-1</pub:sizeOfDataChunkDownload>
				</pub:reportRequest>
				 </pub:runReport>
	   </soap:Body>
	</soap:Envelope>';
  lc_essjob_reqid_payload     CLOB;
  l_xml                       CLOB;
  lc_request_id               VARCHAR2(20);
  --
  -- XX GL Journal Reconciliation Report related attributes
  gc_csv_attributeFormat         VARCHAR2(50)    := 'csv';  
  gc_journal_recon_req_xdo       VARCHAR2(500)   := '/Custom/Financials/XX GL Journal Reconciliation Report.xdo';  
  gc_journal_recon_req_payload_s CLOB := '<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:pub="http://xmlns.oracle.com/oxp/service/PublicReportService">
	   <soap:Header/>
	   <soap:Body>
		  <pub:runReport>
			 <pub:reportRequest>
			   <pub:attributeFormat>'||gc_csv_attributeFormat||'</pub:attributeFormat>
			   <pub:parameterNameValues>
                  <pub:item>
                     <pub:name>p_group_id</pub:name>
                     <pub:values>
                        <pub:item>';
  gc_journal_recon_req_payload_e CLOB := '</pub:item>
                     </pub:values>
                  </pub:item>
            </pub:parameterNameValues>
				<pub:reportAbsolutePath>'||gc_journal_recon_req_xdo||'</pub:reportAbsolutePath>
				<pub:sizeOfDataChunkDownload>-1</pub:sizeOfDataChunkDownload>
				</pub:reportRequest>
				 </pub:runReport>
	   </soap:Body>
	</soap:Envelope>';
  lc_journal_recon_payload    CLOB;
  lc_base64_journal_recon_op  CLOB;
  lc_recon_filename           VARCHAR2(200);
  lc_blob_journal_recon_op    BLOB;
  
  -- BLOB to File related variables
  l_blob_len  INTEGER;
  lr_buffer   RAW(32767);
    
BEGIN
  --
  -- Asses Data Quality for the given Ledger/ GroupId
  --
  xx_gl_journal_prevld_pkg.validate_gl_journals(p_ledger_name => lc_ledger_name, o_succ_rec_cnt => ln_succ_rec_cnt);
  dbms_output.put_line('CP0:ln_succ_rec_cnt-'||ln_succ_rec_cnt);
  
  IF (ln_succ_rec_cnt <= 0)
  THEN
	raise_application_error (-20022,'No elgible records to process');
  END IF;
  
  --
  -- Execute the SQL Query using DBMS_SQL dynamically and write to a CLOB variable
  --
  ln_cursor_id := DBMS_SQL.OPEN_CURSOR;
  DBMS_SQL.PARSE(ln_cursor_id, lc_sql_text, DBMS_SQL.NATIVE);
  ln_exec_id := DBMS_SQL.EXECUTE(ln_cursor_id);
  DBMS_SQL.DESCRIBE_COLUMNS(ln_cursor_id, ln_col_count, desc_rec_tab);
  
  -- Get all columns
  FOR j in 1..ln_col_count
  LOOP
    CASE desc_rec_tab(j).col_type
      WHEN 1 THEN DBMS_SQL.DEFINE_COLUMN(ln_cursor_id,j,lc_varchar_val,2000);
      WHEN 2 THEN DBMS_SQL.DEFINE_COLUMN(ln_cursor_id,j,ln_num_val);
      WHEN 12 THEN DBMS_SQL.DEFINE_COLUMN(ln_cursor_id,j,ld_date_val);
      ELSE
        DBMS_SQL.DEFINE_COLUMN(ln_cursor_id,j,lc_varchar_val,2000);
    END CASE;
  END LOOP;
  
  -- Iterate to get all the columns in a row, move on to the next row until all the rows are fetched
  LOOP
    ln_row_exists := DBMS_SQL.FETCH_ROWS(ln_cursor_id);
    EXIT WHEN ln_row_exists = 0;
    lc_data := NULL;
	  
    FOR j in 1..ln_col_count
    LOOP
      CASE desc_rec_tab(j).col_type
        WHEN 1 
	    THEN 
	  	  DBMS_SQL.COLUMN_VALUE(ln_cursor_id,j,lc_varchar_val);
          lc_data := LTRIM(lc_data||',"'||lc_varchar_val||'"',',');
        WHEN 2 
	  	THEN 
	  	  DBMS_SQL.COLUMN_VALUE(ln_cursor_id,j,ln_num_val);
          lc_data := LTRIM(lc_data||','||ln_num_val,',');
        WHEN 12 
	  	THEN 
	  	  DBMS_SQL.COLUMN_VALUE(ln_cursor_id,j,ld_date_val);
          lc_data := LTRIM(lc_data||','||TO_CHAR(ld_date_val,'YYYY/MM/DD'),',');
        ELSE
          DBMS_SQL.COLUMN_VALUE(ln_cursor_id,j,lc_varchar_val);
          lc_data := LTRIM(lc_data||',"'||lc_varchar_val||'"',',');
      END CASE;
    END LOOP;
	lc_dataset := lc_dataset||lc_data||CHR(10);
  END LOOP;
  
  --dbms_output.put_line('CP1:lc_dataset-'||lc_dataset);
  dbms_output.put_line('CP1:Data Set Fetched');
  
  --
  -- write the CLOB to a file in DBA Directory
  --
  BEGIN
    l_file := UTL_FILE.FOPEN(l_dir, l_file_name, 'w', 32767);
    LOOP
      DBMS_LOB.READ (lc_dataset, l_amount, l_pos, l_buffer);
      UTL_FILE.PUT(l_file, l_buffer);
      UTL_FILE.FFLUSH(l_file);
      l_pos := l_pos + l_amount;
    END LOOP;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF UTL_FILE.IS_OPEN(l_file) THEN
        UTL_FILE.FCLOSE(l_file);
      END IF;
	WHEN OTHERS THEN
      UTL_FILE.FCLOSE(l_file);
      RAISE;
  END;
  dbms_output.put_line('CP2:File is created in STAGE_DIR');
  
  --
  -- Add file(s) to zip and get the BLOB.
  -- Since Journal has one sheet, hence no need of iteration to add multiple csv files to the zip  
  --
  lb_bfile := BFILENAME(l_dir,l_file_name);
  -- open the bfile and get the initial file size
  dbms_lob.fileopen(lb_bfile);
  ln_size := dbms_lob.getlength(lb_bfile);
	  
  dbms_lob.createtemporary(lb_blob, true);
	  
  IF DBMS_LOB.getlength(lb_bfile) > 0 
  THEN
    DBMS_LOB.loadblobfromfile(
        dest_lob    => lb_blob
      , src_bfile   => lb_bfile
      , amount      => DBMS_LOB.lobmaxsize
      , dest_offset => ln_dest_offset
      , src_offset  => ln_src_offset
	);
  END IF;
	  
  apex_zip.add_file(
      p_zipped_blob   => lb_zip
    , p_file_name     => l_file_name
    , p_content       => lb_blob
  );
  
  apex_zip.finish(p_zipped_blob   => lb_zip); 
  dbms_output.put_line('CP3:ZIP is created');
  
  --
  -- Get the Base64 encoding for the ZIP BLOB
  --
  FOR i IN 0 .. TRUNC((DBMS_LOB.getlength(lb_zip) - 1 )/l_step) LOOP
    lc_base64_zip := lc_base64_zip || UTL_RAW.cast_to_varchar2(UTL_ENCODE.base64_encode(DBMS_LOB.substr(lb_zip, l_step, i * l_step + 1)));
  END LOOP;
  -- Empty the BLOB once the base64 encoding is created
  lb_zip := EMPTY_BLOB();
  dbms_output.put_line('CP4:Base64 encoding created');
  
  --
  -- Properties String
  --
  lc_gl_param_list := 'US Primary Ledger,Spreadsheet,US Primary Ledger,'||ln_group_id||',N,N,N';
  --lc_gl_param_list := 'US Primary Ledger,Spreadsheet,US Primary Ledger,200,N,N,N';
  dbms_output.put_line('CP5:Properties String derived');
  
  --
  -- Prepare SOAP Payload
  --
  lc_soap_request := gc_gl_journal_payload_begin
                       ||'<typ:document>
                       <erp:Content>'||lc_base64_zip||'</erp:Content>
                       <erp:FileName>'||lc_zipfile_name||'</erp:FileName>
                       <erp:ContentType>'||gc_zip_mimetype||'</erp:ContentType>
                       <erp:DocumentTitle>'||lc_doc_title||'</erp:DocumentTitle>
                       <erp:DocumentAuthor>'||gc_username||'</erp:DocumentAuthor>
                       <erp:DocumentSecurityGroup>'||gc_doc_security_group||'</erp:DocumentSecurityGroup>
                       <erp:DocumentAccount>'||gc_gl_doc_account||'</erp:DocumentAccount>
                       </typ:document>
                       <typ:jobDetails>
                       <erp:JobName>'||gc_gl_job_name||'</erp:JobName>
                       <erp:ParameterList>'||lc_gl_param_list||'</erp:ParameterList>
                       </typ:jobDetails>
                       <typ:notificationCode>'||gc_notify_code||'</typ:notificationCode>
                       <typ:callbackURL></typ:callbackURL>
                       <typ:jobOptions>'||lc_job_options||'</typ:jobOptions>'
					   ||gc_gl_journal_payload_end;
					   
  dbms_output.put_line('CP6:SOAP Request Created');
  
  --
  -- Invoke importBulkData of ERP Integration Service
  --
  lx_xml_response := 
	  APEX_WEB_SERVICE.MAKE_REQUEST(
          p_url       => gc_erpint_url
        , p_version   => gc_version_11
        , p_action    => lc_action
		, p_envelope  => lc_soap_request
        , p_username  => gc_username
        , p_password  => gc_password 
	  );
	  
  lc_resp_clob := lx_xml_response.getClobVal();
	
  -- Work Around	
  lc_processid:= REGEXP_SUBSTR(SUBSTR(lc_resp_clob,(instr(lc_resp_clob,'</result>'))-10,15),'[0-9]+');
  DBMS_OUTPUT.put_line('CP7:ESS Process Id=' || lc_processid);
      
  -- actual way of doing, issue with APEX_WEB_SERVICE.MAKE_REQUEST, need SR to provide patch to fix
  /*lc_soap_response := APEX_WEB_SERVICE.PARSE_XML(
      p_xml   => l_xml
    , p_xpath => '//result/text()'
    ,p_ns    => 'xmlns:ns0="http://xmlns.oracle.com/apps/financials/commonModules/shared/model/erpIntegrationService/types/"'
  );
  DBMS_OUTPUT.put_line('ESS Process Id=' || lc_soap_response);*/
  
  --
  -- Get ESS Job Status of Load Interface File for Import ESS Job
  --
  lx_xml_response := NULL;
  lc_resp_clob := NULL;
  
  lc_essjob_status_payload:= gc_essjob_status_payload_begin||lc_processid||gc_essjob_status_payload_end;
  LOOP
	lx_xml_response := 
	  APEX_WEB_SERVICE.MAKE_REQUEST(
          p_url       => gc_erpint_url
        , p_version   => gc_version_11
        , p_action    => lc_essjobstat_action
		, p_envelope  => lc_essjob_status_payload
        , p_username  => gc_username
        , p_password  => gc_password 
	  );
	  
	lc_resp_clob := lx_xml_response.getClobVal();
	
    -- Work Around	
    lc_status:= REGEXP_SUBSTR(SUBSTR(lc_resp_clob,(instr(lc_resp_clob,'</result>'))-10,15),'[A-Z]+');
	dbms_session.sleep(30);
	ln_timer_cnt := ln_timer_cnt+1;
	  
	-- If final status falls into the following or loop count value is 10, exit the loop
	IF lc_status IN ('SUCCEEDED','ERROR','WARNING','CANCELLED') OR ln_timer_cnt = 10
	THEN
	  EXIT;
	END IF;
  END LOOP;
  DBMS_OUTPUT.put_line('CP8:ESS Job Status of Load Interface File for Import=' || lc_status);
  
  IF lc_status IS NOT NULL AND lc_status = 'SUCCEEDED'
  THEN
	lc_processid  := NULL;
	lc_status     := NULL;
	ln_timer_cnt  := 0;
	lc_essjob_reqid_payload := gc_essjob_req_payload_begin||ln_group_id||gc_essjob_req_payload_end;
	
	-- Invoke get_report_xml to get the Process Id of Import Journals ESS Job
	xx_webservice_util_pkg.get_report_xml(
        lc_essjob_reqid_payload
	  , l_xml 
	);
	
	FOR r IN (
       SELECT extractvalue(VALUE(p), '/G_1/REQUESTID/text()') AS REQUESTID
         FROM TABLE ( xmlsequence(EXTRACT(xmltype(l_xml), '/DATA_DS/G_1')) ) p
	)
	LOOP
	  lc_request_id := r.requestid;
	END LOOP;
	dbms_output.put_line('CP9:Request Id of Import Journals='||lc_request_id);
	
	IF NVL(lc_request_id,'NA') <> 'NA'
	THEN
	  --
	  -- Get ESS Job Status of Import Journals ESS Job
	  --
	  lx_xml_response := NULL;
      lc_resp_clob := NULL;
      lc_essjob_status_payload := NULL;
      lc_essjob_status_payload:= gc_essjob_status_payload_begin||lc_request_id||gc_essjob_status_payload_end;
      LOOP
	    lx_xml_response := 
	      APEX_WEB_SERVICE.MAKE_REQUEST(
              p_url       => gc_erpint_url
            , p_version   => gc_version_11
            , p_action    => lc_essjobstat_action
		    , p_envelope  => lc_essjob_status_payload
            , p_username  => gc_username
            , p_password  => gc_password 
	      );
	  
	    lc_resp_clob := lx_xml_response.getClobVal();
	
        -- Work Around	
        lc_status:= REGEXP_SUBSTR(SUBSTR(lc_resp_clob,(INSTR(lc_resp_clob,'</result>'))-10,15),'[A-Z]+');
	    dbms_session.sleep(30);
	    ln_timer_cnt := ln_timer_cnt+1;
	  
	    -- If final status falls into the following or loop count value is 10, exit the loop
	    IF lc_status IN ('SUCCEEDED','ERROR','WARNING','CANCELLED') OR ln_timer_cnt = 10
	    THEN
	      EXIT;
	    END IF;
      END LOOP;
	
      DBMS_OUTPUT.put_line('CP10:ESS Job Status of Import Journals=' || lc_status);
	
	  IF lc_status IS NOT NULL AND lc_status = 'SUCCEEDED'
	  THEN
	    lc_journal_recon_payload := gc_journal_recon_req_payload_s||ln_group_id||gc_journal_recon_req_payload_e;
	  
	    -- Invoke Report Service to get the Base64 encoded reportBytes
	    xx_webservice_util_pkg.invoke_report_service(lc_journal_recon_payload,lc_base64_journal_recon_op);
		  
	    lc_blob_journal_recon_op := xx_common_util_pkg.decode_base64(lc_base64_journal_recon_op);
	    lc_recon_filename := 'GL Journal Recon Report Output_'||ln_group_id||'.csv';
	  
	    BEGIN
	      l_file := NULL;
		  l_pos  := 1;
		  l_amount := 32767;
          l_blob_len := DBMS_LOB.getlength(lc_blob_journal_recon_op);
    
          -- Open the destination file.
          l_file := UTL_FILE.fopen(gc_dba_dir,lc_recon_filename,'wb', 32767);
    
          -- Read chunks of the BLOB and write them to the file
          -- until complete.
          WHILE l_pos <= l_blob_len LOOP
            DBMS_LOB.read(lc_blob_journal_recon_op, l_amount, l_pos, lr_buffer);
            UTL_FILE.put_raw(l_file, lr_buffer, TRUE);
            l_pos := l_pos + l_amount;
          END LOOP;
  
          -- Close the file.
          UTL_FILE.fclose(l_file);
  
        EXCEPTION
          WHEN OTHERS THEN
            -- Close the file if something goes wrong.
            IF UTL_FILE.is_open(l_file) THEN
              UTL_FILE.fclose(l_file);
            END IF;
            RAISE;
        END;
	  
	    -- Insert the BLOB into a table with BLOB column
	    INSERT INTO xx_blob_tbl VALUES(lc_blob_journal_recon_op);
	    COMMIT;
        dbms_output.put_line('CP11:Imported Successfully!! Downloaded the Recon...');
	  END IF;
	ELSE
	  dbms_output.put_line('CP9:Request Id of Import Journals - NOT FOUND');
    END IF;
  END IF;
EXCEPTION
  WHEN OTHERS
  THEN
    dbms_output.put_line('Error:'||SUBSTR(SQLERRM,1,300));
END;