CREATE OR REPLACE PACKAGE BODY xx_common_util_pkg
AS

  /*------------------------------------------
  --
  -- Author: Raja
  -- Version                  Description
  --  v1                      added decode_base64, convert_to_xml
  --  v2                      added file_name_rec_typ, file_name_tbl_typ,clob_to_blob,
  --                          write_clob2file,generate_zipblob,base64encode
  --------------------------------------------*/
  
  --
  -- Function to decode a Base64 CLOB into a BLOB
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
  
  -- Added as part of v2
  --
  -- Prepare Data from each entity table of an object
  -- DBMS_SQL package is used to dynamically execute a sql query and fetch rows
  --
  FUNCTION prepare_data(
      p_sql_text        IN CLOB
	, p_header_required IN VARCHAR2 DEFAULT 'N'
  )
  RETURN CLOB
  IS
       
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
	lc_sql_text    CLOB := p_sql_text;
  BEGIN
	
	dbms_output.put_line('lc_sql_text='||lc_sql_text);
	
	IF lc_sql_text IS NOT NULL
	THEN
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
	  
	  -- Print Header (Optional)
	  IF p_header_required = 'Y'
	  THEN
	    FOR i in 1..ln_col_count
        LOOP
          lc_data := ltrim(lc_data||','||lower(desc_rec_tab(i).col_name),',');
        END LOOP;
	    lc_dataset := lc_data;
	  END IF;
	  
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
	ELSE
	  lc_dataset := NULL;
	END IF;
	RETURN lc_dataset;
  EXCEPTION
    WHEN OTHERS
    THEN
      lc_dataset := NULL;
      RETURN lc_dataset;
  END prepare_data;
  
  --
  -- Takes CLOB and return BLOB
  --
  FUNCTION clob_to_blob(
    p_clob IN CLOB
  ) 
  RETURN BLOB 
  IS
    v_blob        BLOB;
    v_offset      NUMBER DEFAULT 1;
    v_amount      NUMBER DEFAULT 4096;
    v_offsetwrite NUMBER DEFAULT 1;
    v_amountwrite NUMBER;
    v_buffer      VARCHAR2(4096 CHAR);
  BEGIN
    dbms_lob.createtemporary(v_blob, TRUE);
    BEGIN
      LOOP
        dbms_lob.READ(p_clob, v_amount, v_offset, v_buffer);
        v_amountwrite := utl_raw.length(utl_raw.cast_to_raw(v_buffer));
        dbms_lob.WRITE(v_blob, v_amountwrite, v_offsetwrite, utl_raw.cast_to_raw(v_buffer));
        v_offsetwrite := v_offsetwrite + v_amountwrite;
        v_offset := v_offset + v_amount;
        v_amount := 4096;
      END LOOP;
    EXCEPTION
      WHEN no_data_found 
	  THEN
        NULL;
	  WHEN OTHERS
	  THEN
	    NULL;
    END;
    RETURN v_blob;
  END clob_to_blob;
  
  --
  -- write clob into file
  --
  PROCEDURE write_clob2file(
      p_clob      IN CLOB
	, p_dir       IN VARCHAR2
	, p_file_name IN VARCHAR2
  )
  IS
    l_file      UTL_FILE.FILE_TYPE;
    l_clob      CLOB;
    l_buffer    VARCHAR2(32767);
    l_amount    BINARY_INTEGER := 32767;
    l_pos       INTEGER := 1;
	l_dir       VARCHAR2(100);
	l_file_name VARCHAR2(150);
	
  BEGIN
    l_clob      := p_clob;
	l_dir       := p_dir;
	l_file_name := p_file_name;
	
	-- Delete the file first
	BEGIN
      DBMS_CLOUD.DELETE_FILE ( 
       directory_name => l_dir,
       file_name      => l_file_name);
	EXCEPTION
	  WHEN OTHERS
	  THEN
	    NULL;
    END;
	
    l_file := UTL_FILE.FOPEN(l_dir, l_file_name, 'w', 32767);

    LOOP
      DBMS_LOB.READ (l_clob, l_amount, l_pos, l_buffer);
      UTL_FILE.PUT(l_file, l_buffer);
      UTL_FILE.FFLUSH(l_file);
      l_pos := l_pos + l_amount;
    END LOOP;
	
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF UTL_FILE.IS_OPEN(l_file) THEN
        UTL_FILE.FCLOSE(l_file);
      END IF;
    WHEN UTL_FILE.INVALID_PATH THEN
      UTL_FILE.FCLOSE(l_file);
      RAISE_APPLICATION_ERROR(-20000, 'File location is invalid.');
      
    WHEN UTL_FILE.INVALID_MODE THEN
      UTL_FILE.FCLOSE(l_file);
      RAISE_APPLICATION_ERROR(-20001, 'The open_mode parameter in FOPEN is invalid.');
    
    WHEN UTL_FILE.INVALID_FILEHANDLE THEN
      UTL_FILE.FCLOSE(l_file);
      RAISE_APPLICATION_ERROR(-20002, 'File handle is invalid.');
    
    WHEN UTL_FILE.INVALID_OPERATION THEN
      UTL_FILE.FCLOSE(l_file);
      RAISE_APPLICATION_ERROR(-20003, 'File could not be opened or operated on as requested.');
    
    WHEN UTL_FILE.READ_ERROR THEN
      UTL_FILE.FCLOSE(l_file);
      RAISE_APPLICATION_ERROR(-20004, 'Operating system error occurred during the read operation.');
    
    WHEN UTL_FILE.WRITE_ERROR THEN
      UTL_FILE.FCLOSE(l_file);
      RAISE_APPLICATION_ERROR(-20005, 'Operating system error occurred during the write operation.');
    
    WHEN UTL_FILE.INTERNAL_ERROR THEN
      UTL_FILE.FCLOSE(l_file);
      RAISE_APPLICATION_ERROR(-20006, 'Unspecified PL/SQL error.');
    
    WHEN UTL_FILE.CHARSETMISMATCH THEN
      UTL_FILE.FCLOSE(l_file);
      RAISE_APPLICATION_ERROR(-20007, 'A file is opened using FOPEN_NCHAR, but later I/O ' ||
                                      'operations use nonchar functions such as PUTF or GET_LINE.');
    
    WHEN UTL_FILE.FILE_OPEN THEN
      UTL_FILE.FCLOSE(l_file);
      RAISE_APPLICATION_ERROR(-20008, 'The requested operation failed because the file is open.');
    
    WHEN UTL_FILE.INVALID_MAXLINESIZE THEN
      UTL_FILE.FCLOSE(l_file);
      RAISE_APPLICATION_ERROR(-20009, 'The MAX_LINESIZE value for FOPEN() is invalid; it should ' || 
                                      'be within the range 1 to 32767.');
    
    WHEN UTL_FILE.INVALID_FILENAME THEN
      UTL_FILE.FCLOSE(l_file);
      RAISE_APPLICATION_ERROR(-20010, 'The filename parameter is invalid.');
    
    WHEN UTL_FILE.ACCESS_DENIED THEN
      UTL_FILE.FCLOSE(l_file);
      RAISE_APPLICATION_ERROR(-20011, 'Permission to access to the file location is denied.');
    
    WHEN UTL_FILE.INVALID_OFFSET THEN
      UTL_FILE.FCLOSE(l_file);
      RAISE_APPLICATION_ERROR(-20012, 'The ABSOLUTE_OFFSET parameter for FSEEK() is invalid; ' ||
                                      'it should be greater than 0 and less than the total ' ||
                                      'number of bytes in the file.');
    
    WHEN UTL_FILE.DELETE_FAILED THEN
      UTL_FILE.FCLOSE(l_file);
      RAISE_APPLICATION_ERROR(-20013, 'The requested file delete operation failed.');
    
    WHEN UTL_FILE.RENAME_FAILED THEN
      UTL_FILE.FCLOSE(l_file);
      RAISE_APPLICATION_ERROR(-20014, 'The requested file rename operation failed.');
    
    WHEN OTHERS THEN
      UTL_FILE.FCLOSE(l_file);
      RAISE;
  END write_clob2file;
  
  --
  -- Function to generate zip from files in Storage/ File System
  -- and return as BLOB
  --
  FUNCTION generate_zipblob(
      p_dba_dir    IN VARCHAR2
    , pt_filenames IN file_name_tbl_typ
  )
  RETURN BLOB
  IS
    lb_bfile          BFILE;
	lb_blob           BLOB;
	lb_zip            BLOB;
	ln_size           INTEGER;
	ln_dest_offset    INTEGER := 1;
    ln_src_offset     INTEGER := 1;
	lc_filename       VARCHAR2(500);
    lt_filenames      file_name_tbl_typ := pt_filenames;
  BEGIN
    FOR i IN lt_filenames.FIRST..lt_filenames.LAST
	LOOP
	  lc_filename := lt_filenames(i).file_name;
	  lb_bfile := BFILENAME(p_dba_dir,lc_filename);
	  -- open the bfile and get the initial file size
      dbms_lob.fileopen(lb_bfile);
      --ln_size := dbms_lob.getlength(lb_bfile);
	  
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
        , p_file_name     => lc_filename
        , p_content       => lb_blob
      );
	  
	END LOOP;
	apex_zip.finish(p_zipped_blob   => lb_zip);
	RETURN lb_zip;
  EXCEPTION
    WHEN OTHERS
	THEN
	  lb_zip := EMPTY_BLOB();
      RETURN lb_zip;
  END generate_zipblob;
  
  --
  -- Write BLOB to File
  --
  PROCEDURE blob2file(
      p_dba_dir      VARCHAR2
	, p_file_name    VARCHAR2
    , p_blob_content BLOB
  )
  IS
    l_file      UTL_FILE.FILE_TYPE;
    l_buffer    RAW(32767);
    l_amount    BINARY_INTEGER := 32767;
    l_pos       INTEGER := 1;
    l_blob      BLOB    := p_blob_content;
    l_blob_len  INTEGER;
  BEGIN
  
    -- Delete the file first
	BEGIN
      DBMS_CLOUD.DELETE_FILE ( 
       directory_name     => p_dba_dir,
       file_name          => p_file_name);
	EXCEPTION
	  WHEN OTHERS
	  THEN
	    NULL;
    END;
    
    l_blob_len := DBMS_LOB.getlength(l_blob);
    
    -- Open the destination file.
    l_file := UTL_FILE.fopen(p_dba_dir,p_file_name,'wb', 32767);
    
    -- Read chunks of the BLOB and write them to the file
    -- until complete.
    WHILE l_pos <= l_blob_len LOOP
      DBMS_LOB.read(l_blob, l_amount, l_pos, l_buffer);
      UTL_FILE.put_raw(l_file, l_buffer, TRUE);
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
  END blob2file;
  
  --
  -- Encodes a BLOB into a Base64 CLOB
  --
  FUNCTION base64encode(p_blob IN BLOB)
  RETURN CLOB
  IS
    l_clob CLOB;
    l_step PLS_INTEGER := 12000; -- make sure you set a multiple of 3 not higher than 24573
  BEGIN
    FOR i IN 0 .. TRUNC((DBMS_LOB.getlength(p_blob) - 1 )/l_step) LOOP
      l_clob := l_clob || UTL_RAW.cast_to_varchar2(UTL_ENCODE.base64_encode(DBMS_LOB.substr(p_blob, l_step, i * l_step + 1)));
    END LOOP;
    RETURN l_clob;
  EXCEPTION
    WHEN OTHERS
	THEN
	  RETURN NULL;
  END;
  
  --
  -- Get Parameters for Import Job in PL/SQL Table (Column to row transpose is done)
  --
  FUNCTION get_parameters(
      p_unique_id_val1    IN  VARCHAR2
    , p_unique_id_val2    IN  VARCHAR2
    , p_unique_id_val3    IN  VARCHAR2
  ) RETURN gc_var_tbl
  IS
    CURSOR lcu_get_parameters(
        p_unique_id_val1  VARCHAR2
	  , p_unique_id_val2  VARCHAR2
	  , p_unique_id_val3  VARCHAR2
	)
	IS
	  SELECT   unique_id_val1
             , unique_id_val2
	         , unique_id_val3
	         , val 
        FROM   xx_parameters_lookup 
      UNPIVOT ( val FOR COL IN 
                  (Param_value1,param_value2,param_value3,param_value4,param_value5,param_value6,param_value7,param_value8,param_value9,param_value10))
       WHERE   unique_id_val1 = p_unique_id_val1 
         AND   NVL(unique_id_val2,1) = NVL(p_unique_id_val2,1)
         AND   NVL(unique_id_val3,1) = NVL(p_unique_id_val3,1);
		 
    lc_prop_tbl_typ  gc_var_tbl;
	ln_counter       NUMBER := 0;
  BEGIN
    FOR i IN lcu_get_parameters(p_unique_id_val1,p_unique_id_val2,p_unique_id_val3)
	LOOP
      ln_counter := ln_counter+1;
	  lc_prop_tbl_typ(ln_counter) := i.val;
	END LOOP;
	
	RETURN lc_prop_tbl_typ;
	
  EXCEPTION
    WHEN OTHERS
	THEN
	  RETURN lc_prop_tbl_typ;
  END get_parameters;
  -- End v2 changes
END xx_common_util_pkg;