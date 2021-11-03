CREATE TABLE xx_data_pre_vld_errors(
    error_id         NUMBER
  , object_instance  VARCHAR2(150)
  , entity_name      VARCHAR2(150)
  , error_column1    VARCHAR2(150)
  , error_value1     NUMBER
  , error_column2    VARCHAR2(150)
  , error_value2     NUMBER
  , error_column3    VARCHAR2(150)
  , error_value3     NUMBER
  , error_column4    VARCHAR2(150)
  , error_value4     VARCHAR2(500)
  , error_column5    VARCHAR2(150)
  , error_value5     VARCHAR2(500)
  , error_column6    VARCHAR2(150)
  , error_value6     VARCHAR2(500)
  , error_message    VARCHAR2(2000)
  , last_update_date DATE
);

CREATE SEQUENCE xx_error_id_seq START WITH 1 INCREMENT BY 1;