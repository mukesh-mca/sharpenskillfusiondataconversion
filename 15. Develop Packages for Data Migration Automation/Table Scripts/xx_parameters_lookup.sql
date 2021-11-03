CREATE TABLE xx_parameters_lookup(
    param_id            NUMBER
  , unique_id_desc1     VARCHAR2(100)
  , unique_id_val1      VARCHAR2(100)
  , unique_id_desc2     VARCHAR2(100)
  , unique_id_val2      VARCHAR2(100)
  , unique_id_desc3     VARCHAR2(100)
  , unique_id_val3      VARCHAR2(100)
  , param_name1         VARCHAR2(100)
  , param_value1        VARCHAR2(100)
  , param_name2         VARCHAR2(100)
  , param_value2        VARCHAR2(100)
  , param_name3         VARCHAR2(100)
  , param_value3        VARCHAR2(100)
  , param_name4         VARCHAR2(100)
  , param_value4        VARCHAR2(100)
  , param_name5         VARCHAR2(100)
  , param_value5        VARCHAR2(100)
  , param_name6         VARCHAR2(100)
  , param_value6        VARCHAR2(100)
  , param_name7         VARCHAR2(100)
  , param_value7        VARCHAR2(100)
  , param_name8         VARCHAR2(100)
  , param_value8        VARCHAR2(100)
  , param_name9         VARCHAR2(100)
  , param_value9        VARCHAR2(100)
  , param_name10        VARCHAR2(100)
  , param_value10       VARCHAR2(100)
  , last_update_date    DATE
);

CREATE SEQUENCE xx_param_id_seq START WITH 1 INCREMENT BY 1;

INSERT INTO xx_parameters_lookup(param_id,unique_id_desc1,unique_id_val1,param_name1,param_value1,param_name2,param_value2,param_name3,param_value3
,param_name4,param_value4,param_name5,param_value5,param_name6,param_value6,param_name7,param_value7) VALUES
(xx_param_id_seq.nextval,'LEDGER_NAME','US Primary Ledger','DAS','US Primary Ledger','JournalSource','Spreadsheet','LedgerName','US Primary Ledger','GroupId','ALL','AccountErros','N','Summary','N','DFF','N');


INSERT INTO xx_parameters_lookup(param_id,unique_id_desc1,unique_id_val1,unique_id_desc2,unique_id_val2,param_name1,param_value1,param_name2,param_value2,param_name3,param_value3
,param_name4,param_value4,param_name5,param_value5,param_name6,param_value6,param_name7,param_value7) VALUES
(xx_param_id_seq.nextval,'LEDGER_NAME','UK Primary Ledger','CITY','LONDON','DAS','UK Ledger Set','JournalSource','Spreadsheet','LedgerName','UK Primary Ledger-LONDON','GroupId','ALL','AccountErros','N','Summary','N','DFF','N');

INSERT INTO xx_parameters_lookup(param_id,unique_id_desc1,unique_id_val1,unique_id_desc2,unique_id_val2,param_name1,param_value1,param_name2,param_value2,param_name3,param_value3
,param_name4,param_value4,param_name5,param_value5,param_name6,param_value6,param_name7,param_value7) VALUES
(xx_param_id_seq.nextval,'LEDGER_NAME','UK Primary Ledger','CITY','NORWICH','DAS','UK Ledger Set','JournalSource','Spreadsheet','LedgerName','UK Primary Ledger-NORWICH','GroupId','ALL','AccountErros','N','Summary','N','DFF','N');

COMMIT;