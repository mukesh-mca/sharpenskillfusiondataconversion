CREATE OR REPLACE PACKAGE BODY xx_common_util_pkg
AS
  /*------------------------------------------
  --
  -- Author: Raja
  -- Version                  Description
  --  v1                      added decode_base64, convert_to_xml
  --
  --------------------------------------------*/
  
  --
  -- Function to Decodes a Base64 CLOB into a BLOB
  --
  FUNCTION decode_base64 (
    p_clob CLOB
  ) 
  RETURN BLOB 
  AS
    l_blob          BLOB;
	lb_result_blob  BLOB;
    l_raw           RAW(32767);
    l_amt           NUMBER := 7700;
    l_offset        NUMBER := 1;
    l_temp          VARCHAR2(32767);
  BEGIN
    dbms_lob.createtemporary(l_blob, true);
    FOR i in 1 .. ceil(dbms_lob.getlength(p_clob) / l_amt)
    LOOP
      dbms_lob.read(p_clob, l_amt, l_offset, l_temp);    
      l_raw    := utl_encode.base64_decode(utl_raw.cast_to_raw(l_temp));
      dbms_lob.append(l_blob, to_blob(l_raw));
	  l_offset := l_offset + l_amt;
    END LOOP;
	lb_result_blob := l_blob;
	dbms_lob.freetemporary(l_blob);
	
    RETURN lb_result_blob;
  EXCEPTION
    WHEN NO_DATA_FOUND 
	THEN
      dbms_output.put_line('decode_base64:NO_DATA_FOUND'||SUBSTR(SQLERRM,1,200));
	WHEN OTHERS 
	THEN
      dbms_output.put_line('decode_base64:WHEN OTHERS'||SUBSTR(SQLERRM,1,200));
  END;
  
  --
  -- Function to convert blob to Xml data
  --
  FUNCTION convert_to_xml (
    p_blob BLOB
  )
  RETURN CLOB 
  AS
    l_clob       CLOB;
    lc_varchar   VARCHAR2(32767);
    ln_start     PLS_INTEGER := 1;
    ln_buffer    PLS_INTEGER := 32767;
    blob_in      BLOB;
    l_xml        XMLTYPE;
  BEGIN
    dbms_lob.createtemporary(l_clob, true);
    blob_in := p_blob;
    
	FOR i IN 1..ceil(dbms_lob.getlength(blob_in) / ln_buffer) LOOP
      lc_varchar := utl_raw.cast_to_varchar2(dbms_lob.substr(blob_in, ln_buffer, ln_start));

      dbms_lob.writeappend(l_clob, length(lc_varchar), lc_varchar);
      ln_start := ln_start + ln_buffer;
    END LOOP;

    l_xml := xmltype.createxml(l_clob);
    RETURN l_xml.getclobval();
  END;
END xx_common_util_pkg;