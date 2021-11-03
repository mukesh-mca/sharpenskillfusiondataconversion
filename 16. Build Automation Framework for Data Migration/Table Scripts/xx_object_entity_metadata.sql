CREATE TABLE xx_object_entity_metadata(
    object_name      VARCHAR2(150)
  , entity_id        NUMBER
  , entity_name      VARCHAR2(150)
  , entity_stg_table VARCHAR2(150)
  , active_flag      VARCHAR2(1)
  , csv_file_name    VARCHAR2(150)
  , last_update_date DATE
);

CREATE SEQUENCE xx_entity_id_seq START WITH 1 INCREMENT BY 1;


INSERT INTO xx_object_entity_metadata(object_name,entity_id,entity_name,entity_stg_table,active_flag,csv_file_name,last_update_date) 
     VALUES ('JournalImport',xx_entity_id_seq.nextval,'GL_INTERFACE','GL_INTERFACE_STG','Y','GlInterface.csv',SYSDATE);
INSERT INTO xx_object_entity_metadata(object_name,entity_id,entity_name,entity_stg_table,active_flag,csv_file_name,last_update_date) 
     VALUES ('PayablesStandardInvoice',xx_entity_id_seq.nextval,'AP_INVOICES_INTERFACE','AP_INVOICES_INTERFACE_STG','Y','ApInvoicesInterface.csv',SYSDATE);
INSERT INTO xx_object_entity_metadata(object_name,entity_id,entity_name,entity_stg_table,active_flag,csv_file_name,last_update_date) 
     VALUES ('PayablesStandardInvoice',xx_entity_id_seq.nextval,'AP_INVOICE_LINES_INTERFACE','AP_INVOICE_LINES_INTERFACE_STG','Y','ApInvoiceLinesInterface.csv',SYSDATE);

COMMIT;