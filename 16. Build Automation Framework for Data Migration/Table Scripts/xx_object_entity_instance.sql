CREATE TABLE xx_object_entity_instance(
    object_instance_id  NUMBER
  , object_instance     VARCHAR2(150)
  , entity_id           NUMBER
  , entity_active_flag  VARCHAR2(1)
  , last_update_date    DATE
);

CREATE SEQUENCE xx_object_instance_id_seq START WITH 1 INCREMENT BY 1;


INSERT INTO xx_object_entity_instance(object_instance_id,object_instance,entity_id,entity_active_flag,last_update_date) 
     VALUES (xx_object_instance_id_seq.nextval,'JournalImport_US',1,'Y',SYSDATE);

INSERT INTO xx_object_entity_instance(object_instance_id,object_instance,entity_id,entity_active_flag,last_update_date) 
     VALUES (xx_object_instance_id_seq.nextval,'JournalImport_IN',1,'Y',SYSDATE);
	 
INSERT INTO xx_object_entity_instance(object_instance_id,object_instance,entity_id,entity_active_flag,last_update_date) 
     VALUES (xx_object_instance_id_seq.nextval,'PayablesStandardInvoice_IN',2,'Y',SYSDATE);
INSERT INTO xx_object_entity_instance(object_instance_id,object_instance,entity_id,entity_active_flag,last_update_date) 
     VALUES (xx_object_instance_id_seq.nextval,'PayablesStandardInvoice_IN',3,'Y',SYSDATE);

INSERT INTO xx_object_entity_instance(object_instance_id,object_instance,entity_id,entity_active_flag,last_update_date) 
     VALUES (xx_object_instance_id_seq.nextval,'PayablesStandardInvoice_US',2,'Y',SYSDATE);
INSERT INTO xx_object_entity_instance(object_instance_id,object_instance,entity_id,entity_active_flag,last_update_date) 
     VALUES (xx_object_instance_id_seq.nextval,'PayablesStandardInvoice_US',3,'N',SYSDATE);

COMMIT;