CREATE OR REPLACE PACKAGE BODY xx_webservice_util_pkg
AS
  /*------------------------------------------
  --
  -- Author: Raja
  -- Version                  Description
  --  v1                      added invoke_report_service, get_report_xml
  --  v2                      added invoke_importbulkdata_service,
  --                          invoke_getessjobstatus_svc, get_essjob_status
  --------------------------------------------*/
  
  --
  --  To invoke Report Service and get the Base64 Encoded String
  --
  PROCEDURE invoke_report_service (
      p_envelope_payload   IN    CLOB
    , o_payload            OUT   CLOB
  )
  AS
    
	lc_action              VARCHAR2(30)    := 'runReport';
    lc_errmesg             VARCHAR2(3000);
    lc_soap_request        CLOB;
    lc_soap_response       CLOB;
	lx_xml_response        XMLTYPE;
  BEGIN
  
    lc_soap_request     := p_envelope_payload;
    lc_soap_request     := TRIM(lc_soap_request);
	
	-- Invoke SOAP Service using APEX_WEB_SERVICE.MAKE_REQUEST API
	lx_xml_response := 
	  APEX_WEB_SERVICE.MAKE_REQUEST(
          p_url       => gc_report_url
        , p_version   => gc_version
        , p_action    => lc_action
		, p_envelope  => lc_soap_request
        , p_username  => gc_username
        , p_password  => gc_password 
	  );
    
	-- Parse the XML to get the report Bytes (Base64 text)
	o_payload := 
	  APEX_WEB_SERVICE.parse_xml_clob(
        p_xml   => lx_xml_response,
        p_xpath => '//reportBytes/text()',
        p_ns    => 'xmlns="http://xmlns.oracle.com/oxp/service/PublicReportService"'
      );
  EXCEPTION    
    WHEN OTHERS
    THEN
      lc_errmesg := SQLERRM;
      dbms_output.put_line(lc_errmesg);
  END invoke_report_service;
  
  --
  -- Get the Report Output in XML format
  --
  PROCEDURE get_report_xml (
      p_envelope_payload IN  CLOB
    , o_payload          OUT CLOB
  )
  AS
    lc_encoded_data    CLOB;
    lc_result          CLOB;
  BEGIN
  
    invoke_report_service( p_envelope_payload, lc_encoded_data);
						  
    o_payload   := xx_common_util_pkg.convert_to_xml(xx_common_util_pkg.decode_base64(lc_encoded_data));

  END get_report_xml;
  
  -- Added as part of v2
  --
  -- Invoke ERP Integration Service(importBulkData)
  --
  PROCEDURE invoke_importbulkdata_service (
      p_envelope_payload   IN    CLOB
    , o_result             OUT   VARCHAR2
  )
  AS
    lc_action              VARCHAR2(30)    := 'importBulkData';
    lc_errmesg             VARCHAR2(3000);
	lc_soap_request        CLOB;
    lx_xml_response        XMLTYPE;
	lc_resp_clob           CLOB;
    lc_processid           VARCHAR2(20);

  BEGIN
    
	lc_soap_request := p_envelope_payload;
	
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
    --DBMS_OUTPUT.put_line('ESS Process Id=' || lc_processid);
      
	-- actual way of doing, issue with APEX_WEB_SERVICE.MAKE_REQUEST, need SR to provide patch to fix
    /*lc_soap_response := APEX_WEB_SERVICE.PARSE_XML(
        p_xml   => l_xml
      , p_xpath => '//result/text()'
      ,p_ns    => 'xmlns:ns0="http://xmlns.oracle.com/apps/financials/commonModules/shared/model/erpIntegrationService/types/"'
    );
	DBMS_OUTPUT.put_line('ESS Process Id=' || lc_soap_response);*/
	
	o_result := lc_processid;
  EXCEPTION    
    WHEN OTHERS
    THEN
      lc_errmesg := SUBSTR(SQLERRM,1,2999);
      dbms_output.put_line(lc_errmesg);
  END invoke_importbulkdata_service;
  
  --
  -- Invoke ERP Integration Service(getESSJobStatus)
  --
  PROCEDURE invoke_getessjobstatus_svc (
      p_envelope_payload   IN    CLOB
    , o_result             OUT   VARCHAR2
  )
  AS
    lc_action              VARCHAR2(30)    := 'getESSJobStatus';
    lc_errmesg             VARCHAR2(3000);
	lc_soap_request        CLOB;
    lx_xml_response        XMLTYPE;
	lc_resp_clob           CLOB;
    lc_status              VARCHAR2(50);

  BEGIN
    
	lc_soap_request := p_envelope_payload;
	
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
    lc_status:= REGEXP_SUBSTR(SUBSTR(lc_resp_clob,(instr(lc_resp_clob,'</result>'))-10,15),'[A-Z]+');
    --DBMS_OUTPUT.put_line('ESS Job Status=' || lc_status);
      
	-- actual way of doing, issue with APEX_WEB_SERVICE.MAKE_REQUEST, need SR to provide patch to fix
    /*lc_soap_response := APEX_WEB_SERVICE.PARSE_XML(
        p_xml   => l_xml
      , p_xpath => '//result/text()'
      ,p_ns    => 'xmlns:ns0="http://xmlns.oracle.com/apps/financials/commonModules/shared/model/erpIntegrationService/types/"'
    );
	DBMS_OUTPUT.put_line('ESS Process Id=' || lc_soap_response);*/
	
	o_result := lc_status;
  EXCEPTION    
    WHEN OTHERS
    THEN
      lc_errmesg := SUBSTR(SQLERRM,1,2999);
      dbms_output.put_line(lc_errmesg);
  END invoke_getessjobstatus_svc;
  
  --
  -- To get status of the ESS Job being submitted at 30 secs of interval for 10 times
  -- (Timer and no. of times can be increased/ decreased based on data volume, no. ESS servers etc.)
  --
  FUNCTION get_essjob_status(p_request_id IN VARCHAR2)
  RETURN VARCHAR2
  IS
    ln_timer_cnt                NUMBER := 0;
	lc_essjob_status_payload    CLOB;
	lc_status                   VARCHAR2(50);
  BEGIN
    lc_essjob_status_payload:= gc_essjob_status_payload_begin||p_request_id||gc_essjob_status_payload_end;
	
    -- Iterate at the interval of 30secs for 10 times	
	LOOP
	  xx_webservice_util_pkg.invoke_getessjobstatus_svc(lc_essjob_status_payload,lc_status);
	  dbms_session.sleep(30);
	  ln_timer_cnt := ln_timer_cnt+1;
	  
	  -- If final status falls into the following or loop count value is 10, exit the loop
	  IF lc_status IN ('SUCCEEDED','ERROR','WARNING','CANCELLED') OR ln_timer_cnt = 10
	  THEN
		EXIT;
	  END IF;
	END LOOP;
	RETURN lc_status;
  EXCEPTION
    WHEN OTHERS
	THEN
	  RETURN NULL;
  END get_essjob_status;
  -- End v2 Changes
END xx_webservice_util_pkg;