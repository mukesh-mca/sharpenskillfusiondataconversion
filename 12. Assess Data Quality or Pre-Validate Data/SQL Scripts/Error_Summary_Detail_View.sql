-- Error DEtails per Journal Line
SELECT error_column1,
       error_value1,
       LISTAGG(error_message||'-->'|| error_value4 || CHR(10))
 WITHIN GROUP (ORDER BY  error_message) error_message
 FROM xx_data_pre_vld_errors
 GROUP BY error_column1,error_value1;
 
-- Error Summary (count) per unique/combination of error type or category
SELECT error_message,
       COUNT(error_value1)
  FROM (SELECT error_value1,
               LISTAGG(error_message|| CHR(10)) WITHIN GROUP (ORDER BY  error_message) error_message
          FROM xx_data_pre_vld_errors
      GROUP BY error_value1) 
 GROUP BY error_message;


-- Error Summary per Unique Error Type
SELECT error_message,
       COUNT(error_value1)
  FROM xx_data_pre_vld_errors
 GROUP BY error_message;