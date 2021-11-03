DECLARE
    gc_url                  VARCHAR2(2000)  := 'https://ucf6-zxrj-fa-ext.oracledemos.com/fscmService/ErpIntegrationService';
    gc_username             VARCHAR2(100)   := 'Raja.Dutta';
    gc_password             VARCHAR2(100)   := 'Welcome@123';
	gc_version_11           NUMBER          := 1.1;
	gc_doc_security_group   VARCHAR2(50)    := 'FAFusionImportExport';
	gc_zip_mimetype         VARCHAR2(10)    := 'zip';
	gc_gl_doc_Account       VARCHAR2(50)    := 'fin$/generalLedger$/import$';
	gc_gl_job_name          VARCHAR2(500)   := 'oracle/apps/ess/financials/generalLedger/programs/common,JournalImportLauncher';
	gc_notify_code          VARCHAR2(5)     := '30';
	gc_gl_cb_url            VARCHAR2(1000)  := NULL;
    lc_action               VARCHAR2(30)    := 'importBulkData';
    lc_errmesg              VARCHAR2(3000);
    lc_soap_request         CLOB;
    lc_soap_response        CLOB;
	lx_xml_response         XMLTYPE;
	lc_base64_zip           CLOB            := 'UEsDBBQAAAAIACilGlPdEnIqfgAAAL4BAAAPAAAAR2xJbnRlcmZhY2UuY3N283MN1zE2AAMTM0tzU0tzQx0jAyNDfQMLfSMzneCCotTElOKM1NQSHd/M4uTUnJzEvNT80mKd0GAXZIWOOoYGhkCsY25hCCRNgNjAAIJxAUMDAz2ItIurr7+TY4izh5GZgYUhNgFMgFsGClz9XHi5qO89czMD4ryH8B/tvAcAUEsBAh8AFAAAAAgAKKUaU90Scip+AAAAvgEAAA8AJAAAAAAAAAAgAAAAAAAAAEdsSW50ZXJmYWNlLmNzdgoAIAAAAAAAAQAYAFEelJ2MmtcBUR6UnYya1wHtqdPxcprXAVBLBQYAAAAAAQABAGEAAACrAAAAAAA=';
	lc_zipfile_name         VARCHAR2(100)   := 'ImportJournal28061.zip';
	lc_doc_title            VARCHAR2(100)   := 'ImportJournal28061';
	lc_gl_param_list        VARCHAR2(1000)  := 'US Primary Ledger,Spreadsheet,US Primary Ledger,28061,N,N,N';
	lc_job_options          VARCHAR2(1000)  := 'EnableEvent=Y,importOption=Y,purgeOption=Y,ExtractFileType!= NONE';
    lc_resp_clob            CLOB;
    lc_processid            VARCHAR2(20);
	
	
BEGIN

-- Prepare SOAP Payload for importBulkData operation of ERP Integration Service
lc_soap_request := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:typ="http://xmlns.oracle.com/apps/financials/commonModules/shared/model/erpIntegrationService/types/" xmlns:erp="http://xmlns.oracle.com/apps/financials/commonModules/shared/model/erpIntegrationService/">
<soapenv:Body>
<typ:importBulkData>
<typ:document>
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
<typ:jobOptions>'||lc_job_options||'</typ:jobOptions>
</typ:importBulkData>
</soapenv:Body>
</soapenv:Envelope>';

-- Invoke importBulkData operation of ERP Integration Service & Receive SOAP Response
    lx_xml_response := 
	  APEX_WEB_SERVICE.MAKE_REQUEST(
          p_url       => gc_url
        , p_version   => gc_version_11
        , p_action    => lc_action
		, p_envelope  => lc_soap_request
        , p_username  => gc_username
        , p_password  => gc_password 
	  );
      
      lc_resp_clob := lx_xml_response.getClobVal();
	  
-- Parse SOAP Response from importBulkData operation of ERP Integration Service 
-- to get the Request Id of Load Interface File for Import
      lc_processid:= REGEXP_SUBSTR(SUBSTR(lc_resp_clob,(INSTR(lc_resp_clob,'</result>'))-10,15),'[0-9]+');
      DBMS_OUTPUT.put_line('ESS Process Id=' || lc_processid);
      
	  -- actual way of doing, issue with APEX_WEB_SERVICE.MAKE_REQUEST, need SR to provide patch to fix
      /*lc_soap_response := APEX_WEB_SERVICE.PARSE_XML(
        p_xml   => l_xml,
        p_xpath => '//result/text()'
        ,p_ns    => 'xmlns:ns0="http://xmlns.oracle.com/apps/financials/commonModules/shared/model/erpIntegrationService/types/"'
      );
	  DBMS_OUTPUT.put_line('ESS Process Id=' || lc_soap_response);*/
END;