SELECT   unique_id_val1
       , unique_id_val2
	   , unique_id_val3
	   , val 
  FROM   xx_parameters_lookup 
UNPIVOT ( val FOR COL IN 
              (Param_value1,param_value2,param_value3,param_value4,param_value5,param_value6,param_value7,param_value8,param_value9,param_value10))
 WHERE   unique_id_val1 = 'US Primary Ledger' 
   AND   NVL(unique_id_val2,1) = NVL(NULL,1)
   AND   NVL(unique_id_val3,1) = NVL(NULL,1)