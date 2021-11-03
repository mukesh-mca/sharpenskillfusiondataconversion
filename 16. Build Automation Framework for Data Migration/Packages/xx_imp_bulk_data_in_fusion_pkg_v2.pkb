CREATE OR REPLACE PACKAGE BODY xx_imp_bulk_data_in_fusion_pkg
AS
  /*------------------------------------------
  --
  -- Author: Raja
  -- Version                  Description
  --  v1                      added prep_journal_soap_req_payload,
  --                          import_gl_journals
  --  v2                      added xform_build_query
  --------------------------------------------*/
  
  -- Added as part of v2
  --
  -- Transform and Build Query
  --
  FUNCTION xform_build_query(
      p_entity_stg_table   IN VARCHAR2
	, p_object_instance_id IN NUMBER
  ) RETURN CLOB
  IS
    lc_sql_text    CLOB;
	
	CURSOR lcu_get_entity_cols(p_obj_inst_id NUMBER)
	IS
	  SELECT   CASE
                 WHEN XOEICR.rule_type = 'SELECT' AND XOEICR.rule_category = 'DEFAULT'
                   THEN XOEICR.rule_desc||' '||XOEIC.entity_column_name
                 WHEN XOEICR.rule_type = 'SELECT' AND XOEICR.rule_category = 'SUBQUERY'
                   THEN XOEICR.rule_desc||' '||XOEIC.entity_column_name
                 ELSE
                   XOEIC.entity_column_name
			   END entity_column_name
	    FROM   xx_object_entity_instance_cols XOEIC
		     , xx_obj_entity_inst_col_rules XOEICR
	   WHERE   XOEIC.obj_ent_ins_col_id = XOEICR.obj_ent_ins_col_id(+)
	     AND   XOEIC.object_instance_id = p_obj_inst_id
	     AND   include_in_fbdi = 'Y'
	   ORDER BY position_in_fbdi;
	   
    CURSOR lcu_get_ent_cols_where_clause(p_obj_inst_id NUMBER)
	IS
	  SELECT   CASE
                 WHEN XOEICR.rule_type = 'WHERE' AND UPPER(XOEICR.rule_operator) NOT LIKE '%EXISTS'
				   THEN XOEICR.rule_category||' '||XOEIC.entity_column_name||' '||
				        XOEICR.rule_operator||' '||XOEICR.rule_desc
				 WHEN XOEICR.rule_type = 'WHERE' AND XOEICR.rule_operator LIKE '%EXISTS'
				   THEN XOEICR.rule_category||' '||XOEICR.rule_operator||' '||XOEICR.rule_desc
			   END where_clause
	    FROM   xx_object_entity_instance_cols XOEIC
		     , xx_obj_entity_inst_col_rules XOEICR
	   WHERE   XOEIC.obj_ent_ins_col_id = XOEICR.obj_ent_ins_col_id
	     AND   XOEICR.rule_type = 'WHERE'
	     AND   XOEIC.object_instance_id = p_obj_inst_id
	     AND   include_in_fbdi = 'Y'
	   ORDER BY position_in_fbdi;
	   
  BEGIN
    lc_sql_text := 'SELECT ';
	-- iterate through 
    FOR i IN lcu_get_entity_cols(p_object_instance_id)
	LOOP
	  lc_sql_text:= lc_sql_text||i.entity_column_name||',';
	END LOOP;
	
	-- remove the trailing ,
	lc_sql_text := SUBSTR(lc_sql_text,1,INSTR(lc_sql_text,',',-1)-1);
	
	-- add from clause
    lc_sql_text := lc_sql_text || ' FROM ' || p_entity_stg_table;
	
	-- add where clause
	lc_sql_text := lc_sql_text || ' WHERE 1=1 '|| CHR(10);
	
	-- iterate to build the where clause
	FOR i IN lcu_get_ent_cols_where_clause(p_object_instance_id)
	LOOP
	  lc_sql_text:= lc_sql_text||i.where_clause|| CHR(10);
	END LOOP;
	
	RETURN lc_sql_text;
  EXCEPTION
    WHEN OTHERS
	THEN
	  lc_sql_text := NULL;
      RETURN lc_sql_text;
  END xform_build_query;
  -- End v2 changes 
  
  --
  -- Prepare SOAP Request Payload for importBulkData operation
  --
  FUNCTION prep_journal_soap_req_payload(
      p_base64_zip IN CLOB
	, p_param_list IN VARCHAR2
  ) RETURN CLOB
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
      p_gljournal_instance  IN VARCHAR2 -- added as part of v2
	, p_ledger_name         IN VARCHAR2
	, p_group_id            IN NUMBER
	, p_header_required     IN VARCHAR2 DEFAULT 'N'
	, p_verbose_logging     IN VARCHAR2 DEFAULT 'N'
  )
  AS
  
    -- Added as part of v2
	-- Cursor to get Object Details
	CURSOR lcu_get_obj_entity_dtls(p_obj_name VARCHAR2)
	IS
	  SELECT   XOEM.object_name 
	         , XOEM.entity_name
			 , XOEM.entity_stg_table
			 , XOEM.csv_file_name
			 , XOEM.entity_id
			 , XOEI.object_instance_id
			 , XOEI.object_instance
	    FROM   xx_object_entity_instance XOEI
		     , xx_object_entity_metadata XOEM
	   WHERE   XOEM.entity_id = XOEI.entity_id
	     AND   XOEI.object_instance = p_gljournal_instance
	     AND   XOEI.entity_active_flag = 'Y';
	-- End v2 changes
	
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
	lc_object_instance          VARCHAR2(100) := p_gljournal_instance;
	lc_header_required          VARCHAR2(1)   := p_header_required;
	lc_ledger_name              VARCHAR2(100) := p_ledger_name;
	lc_request_id               VARCHAR2(20);
	lc_status                   VARCHAR2(50);
	lc_filename                 VARCHAR2(500);
	lc_recon_filename           VARCHAR2(200);
	lc_gl_param_list            VARCHAR2(1000);
	lt_filenames                xx_common_util_pkg.file_name_tbl_typ := xx_common_util_pkg.file_name_tbl_typ();
	lc_prop_tbl_typ             xx_common_util_pkg.gc_var_tbl;
	
  BEGIN
  
    -- Asses Data Quality for the given Ledger and GroupId
	xx_gl_journal_prevld_pkg.validate_gl_journals(
	    p_object_instance => lc_object_instance
      , p_ledger_name     => lc_ledger_name
	  , o_succ_rec_cnt    => ln_succ_rec_cnt
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
	
	-- Iterate through all entities (v2 changes)
    FOR i IN lcu_get_obj_entity_dtls(p_gljournal_instance)
	LOOP
	  
	  -- If verbose logging is enabled, then will print
	  IF p_verbose_logging = 'Y'
	  THEN
	    dbms_output.put_line('CP1:stg_table-'||i.entity_stg_table||'~inst_id-'||i.object_instance_id);
	  END IF;
	  
	  -- Transform Data & Build Query by applying transformation rules (v2 changes)
	  lc_gl_iface_sql := xform_build_query(
                             p_entity_stg_table   => i.entity_stg_table
	                       , p_object_instance_id => i.object_instance_id
						 );
						 
	  -- Prepare Data from each entity table of an object
	  lc_extracted_data := xx_common_util_pkg.prepare_data(
	      p_sql_text        => lc_gl_iface_sql
	    , p_header_required => lc_header_required
	  );
	  
	  -- If data is prepared in the table post transformation, else stop after raising exception
	  IF lc_extracted_data IS NOT NULL
	  THEN
	    lc_filename := i.csv_file_name;
		
	    -- Export fetched data to CSV
	    xx_common_util_pkg.write_clob2file(
	        p_clob      => lc_extracted_data
	      , p_dir       => gc_dba_dir
	      , p_file_name => lc_filename
	    );
		
		ln_file_idx := ln_file_idx+1;
		lt_filenames.extend;
		-- Keep storing the filenames into a PL/SQL Collection
		lt_filenames(ln_file_idx).file_name := lc_filename;
		
		IF p_verbose_logging = 'Y'
	    THEN
		  dbms_output.put_line('CP2:files-'||lt_filenames(ln_file_idx).file_name);
		END IF;
	  ELSE
	    raise_application_error(-20015,'No Data Fetched');
	  END IF;
	END LOOP;
	
	-- Generate zip for the CSV(s) for all the files passed and will return the BLOB
    lb_zip := xx_common_util_pkg.generate_zipblob(
	              p_dba_dir    => gc_dba_dir
                , pt_filenames => lt_filenames
			  );
	
	IF p_verbose_logging = 'Y'
	THEN
	  dbms_output.put_line('CP3:zip blob length-'||dbms_lob.getlength(lb_zip));
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
	    dbms_output.put_line('CP4:Size of Base64 encoded Zip-'||dbms_lob.getlength(lc_base64_zip));
	  END IF;
	  
	  -- Prepare Parameter LIST(Format:<DAS>,<JournalSource>,<LedgerName>,<GroupId>,<AccountErros>,<Summary>,<DFF>)
	  -- A lookup table is created to store all these for all objects, object instance or unique combination
	  lc_prop_tbl_typ := xx_common_util_pkg.get_parameters(
	                         p_unique_id_val1 => lc_ledger_name
		                   , p_unique_id_val2 => NULL
		                   , p_unique_id_val3 => NULL
	                     );
	  
	  -- Iterate to prepare the .properties file, replace any specific property defined in the lookup
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
	    dbms_output.put_line('CP5:lc_gl_param_list-'||lc_gl_param_list);
	  END IF;
	  
	  -- Invoke prep_journal_soap_req_payload to get the payload for importBulkData
	  lc_soap_req_payload := prep_journal_soap_req_payload(
	                             p_base64_zip => lc_base64_zip
	                           , p_param_list => lc_gl_param_list
	                         );
	  
	  IF p_verbose_logging = 'DNP'
	  THEN
	    dbms_output.put_line('CP6:lc_soap_req_payload-'||lc_soap_req_payload);
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
		
		  IF p_verbose_logging = 'Y' OR p_verbose_logging = 'N'
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