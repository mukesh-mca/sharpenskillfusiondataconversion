CREATE OR REPLACE PACKAGE BODY xx_sync_data_bw_fusion_db_pkg 
AS
  --
  -- To Sync GL Periods Status from Fusion to DBaaS/ ATP/ On-Premise DB
  -- Author: Raja Dutta 
  --
  PROCEDURE sync_gl_periods
  AS
    -- Declare/ Define Variables
    l_xml   CLOB;
	
  BEGIN
    -- Invoke the procedure xx_webservice_util_pkg.get_report_xml
    xx_webservice_util_pkg.get_report_xml(
	    gc_gl_periods_payload
	  , l_xml 
	);
	-- Iterate through the records fetched
	FOR r IN (
      SELECT extractvalue(VALUE(p), '/G_1/LEDGER_NAME/text()') AS ledger_name,
             extractvalue(VALUE(p), '/G_1/PERIOD_NAME/text()') AS period_name,
             extractvalue(VALUE(p), '/G_1/STATUS/text()') AS status,
             extractvalue(VALUE(p), '/G_1/LAST_UPDATE_DATE/text()') AS last_update_date
        FROM TABLE ( xmlsequence(EXTRACT(xmltype(l_xml), '/DATA_DS/G_1')) ) p
    )
	LOOP
	  -- Merge if match found update the status and last update date, if not found then insert
      MERGE INTO xx_gl_periods XGP 
	       USING (SELECT 1 
		            FROM DUAL) d 
			  ON (XGP.period_name=r.period_name 
			      AND XGP.ledger_name = r.ledger_name)
           WHEN MATCHED
		   THEN UPDATE SET   XGP.status = r.status
			               , XGP.last_update_date = r.last_update_date
           WHEN NOT MATCHED 
		   THEN INSERT (  ledger_name
                        , period_name
                        , status
                        , last_update_date) 
				VALUES (  r.ledger_name
                        , r.period_name
                        , r.status
                        , r.last_update_date);
    END LOOP;
	COMMIT;
  END sync_gl_periods;
END xx_sync_data_bw_fusion_db_pkg;