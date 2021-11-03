CREATE TABLE xx_gl_ledger_das_lookup(
    ledger_id        NUMBER
  , ledger_name      VARCHAR2(100)
  , das_id           NUMBER
  , das_name         VARCHAR2(100)
  , last_update_date DATE
);


--INSERT INTO xx_gl_ledger_das_lookup VALUES(300000046975971,'US Primary Ledger',300000046975980,'US Primary Ledger',SYSDATE);
--COMMIT;