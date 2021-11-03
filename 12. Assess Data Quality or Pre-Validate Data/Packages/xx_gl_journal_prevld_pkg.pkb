CREATE OR REPLACE PACKAGE BODY xx_gl_journal_prevld_pkg
AS

  /*------------------------------------------
  --
  -- Author: Raja
  -- Version                  Description
  --  v1                      added validate_gl_journals
  --
  --------------------------------------------*/
  
  --
  -- Validate GL Journals
  --
  PROCEDURE validate_gl_journals(
      p_ledger_name      IN VARCHAR2
	, o_succ_rec_cnt    OUT NUMBER
  )
  IS
    CURSOR lcu_get_journals(p_ledger_name VARCHAR2)
	IS
	  SELECT   GIS.ledger_name
	         , GIS.accounting_date
			 , GIS.segment1
			 , GIS.segment2
			 , GIS.segment3
			 , GIS.segment4
			 , GIS.segment5
			 , GIS.segment6
			 , GIS.entered_dr
			 , GIS.entered_cr
			 , GIS.record_id
		FROM   gl_interface_stg GIS;
	   --WHERE   GIS.ledger_name = p_ledger_name;
	   
	CURSOR lcu_get_error_rec_count
	IS
	  SELECT   COUNT(DISTINCT error_value1) err_count
		FROM   xx_data_pre_vld_errors;
	
	TYPE errors_tbl_typ IS TABLE OF xx_data_pre_vld_errors%ROWTYPE;
	lt_errors_tbl_typ errors_tbl_typ := errors_tbl_typ();
	ln_count        NUMBER := 0;
	ln_tot_rec_cnt  NUMBER := 0;
	ln_err_cnt      NUMBER := 0;
	lc_status       VARCHAR2(2);
	ln_ledger_id    NUMBER;
	lc_entity_name  VARCHAR2(20) := 'GL_INTERFACE';
	lc_err_msg      VARCHAR2(500);
	
  BEGIN
  
    DELETE FROM xx_data_pre_vld_errors;
	COMMIT;
	
    FOR journals_rec IN lcu_get_journals(p_ledger_name)
	LOOP
	  ln_tot_rec_cnt := ln_tot_rec_cnt+1;
	  -- Validate Ledger (though Ledger Name is parameter, 
	  -- it won't enter the cursor loop if Ledger not found, it' for demo only)
	  BEGIN
	    SELECT NVL(ledger_id,0)
		  INTO ln_ledger_id
		  FROM xx_gl_ledger_das_lookup
		 WHERE ledger_name = journals_rec.ledger_name;
		   
		IF ln_ledger_id = 0
		THEN
		  lc_err_msg := 'Ledger Id not found in Cloud';
          ln_count := ln_count+1;
	      lt_errors_tbl_typ.EXTEND;
		  lt_errors_tbl_typ(ln_count).entity_name    := lc_entity_name;
	      lt_errors_tbl_typ(ln_count).error_column1  := 'RECORD_ID';
	      lt_errors_tbl_typ(ln_count).error_value1   := journals_rec.record_id;
	      lt_errors_tbl_typ(ln_count).error_column4  := 'LEDGER_NAME';
	      lt_errors_tbl_typ(ln_count).error_value4   := journals_rec.ledger_name;
	      lt_errors_tbl_typ(ln_count).error_message  := lc_err_msg;   
		END IF;
	  EXCEPTION
	    WHEN NO_DATA_FOUND
		THEN
		  lc_err_msg := 'Ledger Not Found';
          ln_count := ln_count+1;
	      lt_errors_tbl_typ.EXTEND;
		  lt_errors_tbl_typ(ln_count).entity_name    := lc_entity_name;
	      lt_errors_tbl_typ(ln_count).error_column1  := 'RECORD_ID';
	      lt_errors_tbl_typ(ln_count).error_value1   := journals_rec.record_id;
	      lt_errors_tbl_typ(ln_count).error_column4  := 'LEDGER_NAME';
	      lt_errors_tbl_typ(ln_count).error_value4   := journals_rec.ledger_name;
		  lt_errors_tbl_typ(ln_count).error_column5  := 'SQL_ERR';
	      lt_errors_tbl_typ(ln_count).error_value5   := SUBSTR(SQLERRM,1,200);
	      lt_errors_tbl_typ(ln_count).error_message  := lc_err_msg;  
	    WHEN OTHERS
		THEN
		  lc_err_msg := 'Ledger Not Found';
          ln_count := ln_count+1;
	      lt_errors_tbl_typ.EXTEND;
		  lt_errors_tbl_typ(ln_count).entity_name    := lc_entity_name;
	      lt_errors_tbl_typ(ln_count).error_column1  := 'RECORD_ID';
	      lt_errors_tbl_typ(ln_count).error_value1   := journals_rec.record_id;
	      lt_errors_tbl_typ(ln_count).error_column4  := 'LEDGER_NAME';
	      lt_errors_tbl_typ(ln_count).error_value4   := journals_rec.ledger_name;
		  lt_errors_tbl_typ(ln_count).error_column5  := 'SQL_ERR';
	      lt_errors_tbl_typ(ln_count).error_value5   := 'OTHERS-'||SUBSTR(SQLERRM,1,200);
	      lt_errors_tbl_typ(ln_count).error_message  := lc_err_msg;  
	  END;
	  
	  -- Validate GL Period status for the accounting_date
	  BEGIN
	    SELECT NVL(status,'N')
		  INTO lc_status
		  FROM xx_gl_periods
		 WHERE TO_CHAR(journals_rec.accounting_date,'MM-YY') = period_name
		   AND ledger_name = journals_rec.ledger_name;
		   
		IF lc_status NOT IN ('O','F')
		THEN
		  lc_err_msg := 'Period is closed';
          ln_count := ln_count+1;
	      lt_errors_tbl_typ.EXTEND;
		  lt_errors_tbl_typ(ln_count).entity_name    := lc_entity_name;
	      lt_errors_tbl_typ(ln_count).error_column1  := 'RECORD_ID';
	      lt_errors_tbl_typ(ln_count).error_value1   := journals_rec.record_id;
	      lt_errors_tbl_typ(ln_count).error_column4  := 'ACCOUNTING_DATE';
	      lt_errors_tbl_typ(ln_count).error_value4   := journals_rec.accounting_date;
	      lt_errors_tbl_typ(ln_count).error_message  := lc_err_msg;   
		END IF;
	  EXCEPTION
	    WHEN NO_DATA_FOUND
		THEN
		  lc_err_msg := 'Period Not Found';
          ln_count := ln_count+1;
	      lt_errors_tbl_typ.EXTEND;
		  lt_errors_tbl_typ(ln_count).entity_name    := lc_entity_name;
	      lt_errors_tbl_typ(ln_count).error_column1  := 'RECORD_ID';
	      lt_errors_tbl_typ(ln_count).error_value1   := journals_rec.record_id;
	      lt_errors_tbl_typ(ln_count).error_column4  := 'ACCOUNTING_DATE';
	      lt_errors_tbl_typ(ln_count).error_value4   := journals_rec.accounting_date;
		  lt_errors_tbl_typ(ln_count).error_column5  := 'SQL_ERR';
	      lt_errors_tbl_typ(ln_count).error_value5   := SUBSTR(SQLERRM,1,200);
	      lt_errors_tbl_typ(ln_count).error_message  := lc_err_msg;  
	    WHEN OTHERS
		THEN
		  lc_err_msg := 'Period Not Found';
          ln_count := ln_count+1;
	      lt_errors_tbl_typ.EXTEND;
		  lt_errors_tbl_typ(ln_count).entity_name    := lc_entity_name;
	      lt_errors_tbl_typ(ln_count).error_column1  := 'RECORD_ID';
	      lt_errors_tbl_typ(ln_count).error_value1   := journals_rec.record_id;
	      lt_errors_tbl_typ(ln_count).error_column4  := 'ACCOUNTING_DATE';
	      lt_errors_tbl_typ(ln_count).error_value4   := journals_rec.accounting_date;
		  lt_errors_tbl_typ(ln_count).error_column5  := 'SQL_ERR';
	      lt_errors_tbl_typ(ln_count).error_value5   := 'OTHERS-'||SUBSTR(SQLERRM,1,200);
	      lt_errors_tbl_typ(ln_count).error_message  := lc_err_msg;
	  END;
	END LOOP;
    
	-- Insert error records into the xx_data_pre_vld_errors table
	FOR i IN lt_errors_tbl_typ.FIRST..lt_errors_tbl_typ.LAST
	LOOP
	  INSERT INTO xx_data_pre_vld_errors(error_id,entity_name,error_column1,error_value1,error_column4,error_value4,error_column5,error_value5,error_message,last_update_date)
	       VALUES (xx_error_id_seq.nextval,lt_errors_tbl_typ(i).entity_name,lt_errors_tbl_typ(i).error_column1,lt_errors_tbl_typ(i).error_value1,lt_errors_tbl_typ(i).error_column4,lt_errors_tbl_typ(i).error_value4,lt_errors_tbl_typ(i).error_column5,lt_errors_tbl_typ(i).error_value5,lt_errors_tbl_typ(i).error_message, SYSDATE);
	END LOOP;
	COMMIT;
	
	-- Get the error count
	OPEN  lcu_get_error_rec_count;
	FETCH lcu_get_error_rec_count INTO ln_err_cnt;
	CLOSE lcu_get_error_rec_count;
	
	-- Derive success count (total records processed - total failed records)
	o_succ_rec_cnt := ln_tot_rec_cnt - ln_err_cnt;
	
  EXCEPTION
    WHEN OTHERS
	THEN
	  raise_application_error(-20018, 'Fatal Error:'||SUBSTR(SQLERRM,1,200));
  END validate_gl_journals;
END xx_gl_journal_prevld_pkg;