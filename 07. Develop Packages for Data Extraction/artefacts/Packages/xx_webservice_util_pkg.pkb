CREATE OR REPLACE PACKAGE BODY xx_webservice_util_pkg
AS
  /*------------------------------------------
  --
  -- Author: Raja
  -- Version                  Description
  --  v1                      added invoke_report_service, get_report_xml
  --  
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
	
	lx_xml_response := 
	  APEX_WEB_SERVICE.MAKE_REQUEST(
          p_url       => gc_url
        , p_version   => gc_version
        , p_action    => lc_action
		, p_envelope  => lc_soap_request
        , p_username  => gc_username
        , p_password  => gc_password 
	  );

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

END xx_webservice_util_pkg;
/