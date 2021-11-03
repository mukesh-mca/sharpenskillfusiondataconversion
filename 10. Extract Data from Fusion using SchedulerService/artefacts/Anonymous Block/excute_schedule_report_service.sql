DECLARE
  -- report invocation related variables
  lx_xml                    XMLTYPE;
  lc_result                 CLOB;
  -- Parameters
  lc_param_p_source         VARCHAR2(100)   := 'p_source';
  lc_param_val_p_source     VARCHAR2(100)   := 'ISP';
  lc_param_p_inv_num        VARCHAR2(100)   := 'p_inv_num';
  lc_param_val_p_inv_num    VARCHAR2(100)   := '162034inv';
  lc_job_name               VARCHAR2(100)   := 'Test Job3';
  --
  -- SOAP Config Parameters
  gc_schedule_rpt_action    VARCHAR2(30)    := 'scheduleReport';
  gc_url                    VARCHAR2(2000)  := 'https://ucf6-zxnh-fa-ext.oracledemos.com/xmlpserver/services/ScheduleReportWSSService';
  gc_version                NUMBER          := 1.2;
  gc_username               VARCHAR2(100)   := 'Raja.Tran';
  gc_password               VARCHAR2(100)   := 'Welcome@123';
  --
  -- FTP Details
  gc_ftp_server             VARCHAR2(100)   := 'TEST';
  gc_remoteFileDir          VARCHAR2(500)   := '/home/ubuntu/outbound/invoice/';
  gc_remoteFileName         VARCHAR2(100)   := 'Invoice3.csv';
  gc_sftp_option            VARCHAR2(10)    := 'true';
  --
  -- SOAP Payload attributes
  gc_csv_attributeFormat    VARCHAR2(50)    := 'csv';
  gc_save_data_option       VARCHAR2(10)    := 'true';
  gc_save_output_option     VARCHAR2(10)    := 'true';
  gc_sched_public_option    VARCHAR2(10)    := 'true';
  gc_ap_invoice_xdo         VARCHAR2(500)   := '/Custom/Financials/XXDEMO_RTF_TEMPLATE.xdo';
  gc_ap_invoice_payload     CLOB := '<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:sch="http://xmlns.oracle.com/oxp/service/ScheduleReportService">
   <soap:Header/>
   <soap:Body>
      <sch:scheduleReport>
         <scheduleRequest>
            <deliveryChannels>
               <ftpOptions>
                  <ftpServerName>'||gc_ftp_server||'</ftpServerName>
                  <remoteFile>'||gc_remoteFileDir||gc_remoteFileName||'</remoteFile>
                  <sftpOption>'||gc_sftp_option||'</sftpOption>
               </ftpOptions>
            </deliveryChannels>
            <reportRequest>
               <attributeFormat>'||gc_csv_attributeFormat||'</attributeFormat>
               <parameterNameValues>
                  <listOfParamNameValues>
                     <name>'||lc_param_p_source||'</name>
                     <values>'||lc_param_val_p_source||'</values>
                  </listOfParamNameValues>
                  <listOfParamNameValues>
                     <name>'||lc_param_p_inv_num||'</name>
                     <values>'||lc_param_val_p_inv_num||'</values>
                  </listOfParamNameValues>
               </parameterNameValues>
               <reportAbsolutePath>'||gc_ap_invoice_xdo||'</reportAbsolutePath>
            </reportRequest>
            <saveDataOption>'||gc_save_data_option||'</saveDataOption>
            <saveOutputOption>'||gc_save_output_option||'</saveOutputOption>
            <schedulePublicOption>'||gc_sched_public_option||'</schedulePublicOption>
            <userJobName>'||lc_job_name||'</userJobName>
         </scheduleRequest>
      </sch:scheduleReport>
   </soap:Body>
</soap:Envelope>';
	
BEGIN
  DBMS_OUTPUT.put_line('SOAP Request Message Prepared');
  -- Invoke the Report Service
  lx_xml := APEX_WEB_SERVICE.make_request(
              p_url       => gc_url,
              p_version   => gc_version,
              p_action    => gc_schedule_rpt_action,
			  p_envelope  => gc_ap_invoice_payload,
              p_username  => gc_username,
              p_password  => gc_password );
  
  -- Display the whole SOAP document returned
  -- if report returns smaller data set
  --DBMS_OUTPUT.put_line('lx_xml=========>' || lx_xml.getClobVal());
  DBMS_OUTPUT.put_line('Report Service Invoked');
  
  -- Parse SOAP XML Response returned by the Report Service
  lc_result := APEX_WEB_SERVICE.parse_xml_clob(
                 p_xml   => lx_xml,
                 p_xpath => '//scheduleReport/text()',
                 p_ns    => 'xmlns="http://xmlns.oracle.com/oxp/service/ScheduleReportService"'
               );

  DBMS_OUTPUT.put_line('lc_result==========>' || lc_result);
  DBMS_OUTPUT.put_line('SOAP Response Parsed');
EXCEPTION
  WHEN OTHERS
  THEN
    dbms_output.put_line('Error here:'||substr(sqlerrm,1,200));
END;