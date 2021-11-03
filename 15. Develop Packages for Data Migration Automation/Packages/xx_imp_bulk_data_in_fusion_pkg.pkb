CREATE OR REPLACE PACKAGE BODY xx_imp_bulk_data_in_fusion_pkg
AS
  /*------------------------------------------
  --
  -- Author: Raja
  -- Version                  Description
  --  v1                      added prep_journal_soap_req_payload,
  --                          import_gl_journals
  --------------------------------------------*/
  
  --
  -- Prepare SOAP Request Payload for importBulkData operation
  --
  FUNCTION prep_journal_soap_req_payload(
      p_base64_zip IN CLOB
	, p_param_list IN VARCHAR2
  )
  RETURN CLOB
  IS
    lc_soap_request        CLOB;
	lc_gl_param_list       VARCHAR2(1000)  := p_param_list;
	lc_job_options         VARCHAR2(1000)  := 'EnableEvent=Y,importOption=Y,purgeOption=Y,ExtractFileType!= NONE';
	lc_doc_title           VARCHAR2(100)   := 'ImportJournal'||TO_CHAR(SYSDATE,'DDMMYYYYHHMISS');
	lc_zipfile_name        VARCHAR2(100)   := lc_doc_title||'.zip';
	lc_base64_zip          CLOB            := p_base64_zip;
  BEGIN
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
    RETURN lc_soap_request;
  EXCEPTION
    WHEN OTHERS
	THEN
	  lc_soap_request := NULL;
      RETURN lc_soap_request;
  END prep_journal_soap_req_payload;
  
  --
  -- To import GL Journal into Fusion from DBaaS/ ATP/ On-Premise DB 
  -- Full E2E automation/ few steps can be done manually based on client's requirement
  --
  PROCEDURE import_gl_journals(
      p_ledger_name         IN VARCHAR2
	, p_group_id            IN NUMBER
	, p_header_required     IN VARCHAR2 DEFAULT 'N'
	, p_verbose_logging     IN VARCHAR2 DEFAULT 'N'
  )
  AS
	
	-- Declare/ Define Variables
	lc_gl_iface_sql             CLOB;
    lc_extracted_data           CLOB;
    lc_soap_req_payload         CLOB;
	lc_base64_zip               CLOB;
	lc_essjob_reqid_payload     CLOB;
	lc_journal_recon_payload    CLOB;
	lc_base64_journal_recon_op  CLOB; 
	l_xml                       CLOB;
	lb_zip                      BLOB;
	lc_blob_journal_recon_op    BLOB;
	ln_file_idx                 NUMBER := 0;
	ln_succ_rec_cnt             NUMBER := 0;
	ln_timer_cnt                NUMBER := 0;
	lc_header_required          VARCHAR2(1)   := p_header_required;
	lc_ledger_name              VARCHAR2(100) := p_ledger_name;
	lc_request_id               VARCHAR2(20);
	lc_status                   VARCHAR2(50);
	lc_filename                 VARCHAR2(500) := 'GlInterface.csv'; -- FBDI CSV File name;
	lc_recon_filename           VARCHAR2(200);
	lc_gl_param_list            VARCHAR2(1000);
	lt_filenames                xx_common_util_pkg.file_name_tbl_typ := xx_common_util_pkg.file_name_tbl_typ();
	lc_prop_tbl_typ             xx_common_util_pkg.gc_var_tbl;
	
  BEGIN
  
    -- Asses Data Quality for the given Ledger and GroupId
	xx_gl_journal_prevld_pkg.validate_gl_journals(
	    p_ledger_name  => lc_ledger_name
	  , o_succ_rec_cnt => ln_succ_rec_cnt
	);
	  
	IF p_verbose_logging = 'Y'
	THEN
	  dbms_output.put_line('CP0:ln_succ_rec_cnt-'||ln_succ_rec_cnt);
	END IF;
	  
	-- If no valid records found, stop then and there
	IF (ln_succ_rec_cnt <= 0)
	THEN
	  raise_application_error (-20022,'No elgible records to process');
	END IF;
	  
	-- Prepare Data from each entity table of an object
	lc_gl_iface_sql := 'SELECT 
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
	
	lc_extracted_data := xx_common_util_pkg.prepare_data(
	    p_sql_text        => lc_gl_iface_sql
	  , p_header_required => lc_header_required
	);
	  
	IF p_verbose_logging = 'Y'
	THEN
	  dbms_output.put_line('CP1:Data Set Fetched');
	END IF;
	  
	-- If data is prepared in the table post transformation, else stop after raising exception
	IF lc_extracted_data IS NOT NULL
	THEN
	  -- Export fetched data to CSV
	  xx_common_util_pkg.write_clob2file(
	      p_clob      => lc_extracted_data
	    , p_dir       => gc_dba_dir
	    , p_file_name => lc_filename
	  );
	  
	  IF p_verbose_logging = 'Y'
	  THEN
	    dbms_output.put_line('CP2:File is created in STAGE_DIR');
	  END IF;
	  
	  ln_file_idx := ln_file_idx+1;
	  lt_filenames.extend;
	  -- Keep storing the filenames into a PL/SQL Collection
	  lt_filenames(ln_file_idx).file_name := lc_filename;
	ELSE
	  raise_application_error('-20015','No Data Fetched');
	END IF;
	
	-- Generate zip for the CSV(s) for all the files passed and will return the BLOB
    lb_zip := xx_common_util_pkg.generate_zipblob(
	              p_dba_dir    => gc_dba_dir
                , pt_filenames => lt_filenames
			  );
	
	IF p_verbose_logging = 'Y'
	THEN
	  dbms_output.put_line('CP3:ZIP is created');
	END IF;
	
	-- If BLOB(zip) returned
	IF lb_zip IS NOT NULL
	THEN
	  -- Convert BLOB(zip) to Base64encoded text
	  lc_base64_zip := xx_common_util_pkg.base64encode(
	                     p_blob => lb_zip
					   );
	  
	  IF p_verbose_logging = 'Y'
	  THEN
	    dbms_output.put_line('CP4:Base64 encoding created');
	  END IF;
	  
	  -- Prepare Parameter LIST(Format:<DAS>,<JournalSource>,<LedgerName>,<GroupId>,<AccountErros>,<Summary>,<DFF>)
	  -- A lookup table is created to store all these for all objects, object instance or unique combination
	  lc_prop_tbl_typ := xx_common_util_pkg.get_parameters(
	                         p_unique_id_val1 => lc_ledger_name
		                   , p_unique_id_val2 => NULL
		                   , p_unique_id_val3 => NULL
	                     );
	  
	  -- Iterate to prepare the parameter list, replace any specific property defined in the lookup
	  FOR i IN lc_prop_tbl_typ.FIRST..lc_prop_tbl_typ.LAST
	  LOOP
	    lc_gl_param_list := lc_gl_param_list||lc_prop_tbl_typ(i)||',';
		IF i = 4
		THEN
		  lc_gl_param_list := REPLACE(lc_gl_param_list,lc_prop_tbl_typ(i),p_group_id);
		END IF;
	  END LOOP;
	  
	  IF p_verbose_logging = 'Y'
	  THEN
	    dbms_output.put_line('CP5:Properties String derived - ' || lc_gl_param_list);
	  END IF;
	  
	  -- Invoke prep_journal_soap_req_payload to get the payload for importBulkData
	  lc_soap_req_payload := prep_journal_soap_req_payload(
	                             p_base64_zip => lc_base64_zip
	                           , p_param_list => lc_gl_param_list
	                         );
	  
	  IF p_verbose_logging = 'Y'
	  THEN
	    dbms_output.put_line('CP6:SOAP Request Created');
	  END IF;
	
      -- Invoke invoke_importbulkdata_service and get the ESS Process Id
      xx_webservice_util_pkg.invoke_importbulkdata_service(
	      p_envelope_payload => lc_soap_req_payload
		, o_result           => lc_request_id
	  );
	  
	  IF p_verbose_logging = 'Y'
	  THEN
	    dbms_output.put_line('CP7:Request Id of Load Interface File for Import='||lc_request_id);
	  END IF;
	  
	  -- Invoke get_essjob_status to get the status of Load Interface File for Import
	  lc_status := xx_webservice_util_pkg.get_essjob_status(
	                 p_request_id => lc_request_id
	               );
	  
	  IF p_verbose_logging = 'Y'
	  THEN
	    dbms_output.put_line('CP8:Status of Load Interface File for Import='||lc_status);
	  END IF;
	  
	  -- if status is SUCCEEDED then proceed to next steps
	  IF lc_status IS NOT NULL AND lc_status = 'SUCCEEDED'
	  THEN
	    lc_request_id := NULL;
		lc_status     := NULL;
		ln_timer_cnt  := 0;
		
		lc_essjob_reqid_payload := gc_essjob_req_payload_begin||p_group_id||gc_essjob_req_payload_end;
		
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
		
		IF p_verbose_logging = 'Y'
	    THEN
	      dbms_output.put_line('CP9:Request Id of Import Journals='||lc_request_id);
	    END IF;
		
		IF NVL(lc_request_id,'NA') <> 'NA'
		THEN
		  -- Get status of Import Journals
	      lc_status := xx_webservice_util_pkg.get_essjob_status(
	                     p_request_id => lc_request_id
	                   );
		
		  IF p_verbose_logging = 'Y'
	      THEN
	        dbms_output.put_line('CP10:Status of Import Journals='||lc_status);
	      END IF;
	    
		  -- If Import Journals ends up with status as SUCCEEDED, then proceed
	      IF lc_status IS NOT NULL AND lc_status = 'SUCCEEDED'
	      THEN
		    -- Op1: Download Log/Output and place in FTP/ File Server or insert into DB
	        -- Op2.1: Build Recon Report to get the loaded records and counts, place in FTP/ File Server or insert into DB
	        -- Op2.2: Build Error/ Exception Report to get the failed records and counts, place in FTP/ File Server or insert into DB
		    -- Optionaly send email with/ without attachments(above mentioned log/output or report outputs)
		  
		    -- get the recon report output and write to object storage as File and insert as BLOB in a DB table
		    lc_journal_recon_payload := gc_journal_recon_req_payload_s||p_group_id||gc_journal_recon_req_payload_e;
		  
		    -- Invoke Report Service to get the Base64 encoded reportBytes
		    xx_webservice_util_pkg.invoke_report_service(
			    p_envelope_payload => lc_journal_recon_payload
              , o_payload          => lc_base64_journal_recon_op
			);
		  
		    lc_blob_journal_recon_op := xx_common_util_pkg.decode_base64(
			                              p_clob => lc_base64_journal_recon_op
										);
		  
		    lc_recon_filename := 'GL Journal Recon Report Output_'||p_group_id||'.csv';
		    xx_common_util_pkg.blob2file(
			    p_dba_dir      => gc_dba_dir
	          , p_file_name    => lc_recon_filename
              , p_blob_content => lc_blob_journal_recon_op
			);
		  
		    INSERT INTO xx_blob_tbl VALUES(lc_blob_journal_recon_op);
		    COMMIT;
		  
		    IF p_verbose_logging = 'Y'
	        THEN
	          dbms_output.put_line('CP11:Imported Successfully!! Downloaded the Recon...');
	        END IF;
		  
		    ----------- END OF PROCESS ------------
		    -- What's next
		     -- Reconcile Source Data with the Data being imported
			 -- Archive the source data
			 -- Send Email with all reports/ or email with the path where the reports can be downloaded from
		  ELSE
		    raise_application_error(-20024,'Check the status of Import Journal, manually proceed');
		  END IF;
		ELSE
		  raise_application_error(-20025,'Request Id of Import Journals could not be derived, manually proceed');
		END IF;
	  ELSE
	    raise_application_error(-20023,'Check the status of Load Interface File for Import, manually proceed');
	  END IF;
    ELSE 
	  raise_application_error(-20016,'Zip not generated');
	END IF;
  EXCEPTION
    WHEN OTHERS
    THEN
      dbms_output.put_line('Fatal Error:'||SUBSTR(SQLERRM,1,200));
  END import_gl_journals;
END xx_imp_bulk_data_in_fusion_pkg;