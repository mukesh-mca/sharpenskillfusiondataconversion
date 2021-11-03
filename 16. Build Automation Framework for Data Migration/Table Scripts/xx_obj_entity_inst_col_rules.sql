CREATE TABLE xx_obj_entity_inst_col_rules(
    obj_ent_inst_col_rule_id NUMBER
  , obj_ent_ins_col_id       NUMBER
  , rule_type                VARCHAR2(500) -- Values are SELECT/WHERE/ORDER_BY
  , rule_category            VARCHAR2(500) -- Values are SELECT - DEFAULT/SUBQUERY, WHERE - AND/OR
  , rule_operator            VARCHAR2(10)  -- Applicable for WHERE only, Values are (=/<>/IS/IS NOT/IN/NOT IN)
  , rule_desc                VARCHAR2(4000) -- Actual rule/ SUBQUERY
  , last_update_date         DATE
);

CREATE SEQUENCE obj_ent_inst_col_rule_id_seq START WITH 1 INCREMENT BY 1;


INSERT INTO xx_obj_entity_inst_col_rules(obj_ent_inst_col_rule_id,obj_ent_ins_col_id,rule_type,rule_category,rule_desc,last_update_date) 
     VALUES (obj_ent_inst_col_rule_id_seq.nextval,1,'SELECT','DEFAULT','''NEW''',SYSDATE);

INSERT INTO xx_obj_entity_inst_col_rules(obj_ent_inst_col_rule_id,obj_ent_ins_col_id,rule_type,rule_category,rule_desc,last_update_date) 
     VALUES (obj_ent_inst_col_rule_id_seq.nextval,2,'SELECT','SUBQUERY','(SELECT ledger_id FROM xx_gl_ledger_das_lookup WHERE ledger_name='||'''US Primary Ledger'''||')',SYSDATE);
	 
INSERT INTO xx_obj_entity_inst_col_rules(obj_ent_inst_col_rule_id,obj_ent_ins_col_id,rule_type,rule_category,rule_desc,last_update_date) 
     VALUES (obj_ent_inst_col_rule_id_seq.nextval,4,'SELECT','DEFAULT','''Spreadsheet''',SYSDATE);
	 
INSERT INTO xx_obj_entity_inst_col_rules(obj_ent_inst_col_rule_id,obj_ent_ins_col_id,rule_type,rule_category,rule_desc,last_update_date) 
     VALUES (obj_ent_inst_col_rule_id_seq.nextval,5,'SELECT','DEFAULT','''Miscellaneous''',SYSDATE);
	 
INSERT INTO xx_obj_entity_inst_col_rules(obj_ent_inst_col_rule_id,obj_ent_ins_col_id,rule_type,rule_category,rule_desc,last_update_date) 
     VALUES (obj_ent_inst_col_rule_id_seq.nextval,8,'SELECT','DEFAULT','''A''',SYSDATE);
	 
INSERT INTO xx_obj_entity_inst_col_rules(obj_ent_inst_col_rule_id,obj_ent_ins_col_id,rule_type,rule_category,rule_operator,rule_desc,last_update_date) 
     VALUES (obj_ent_inst_col_rule_id_seq.nextval,92,'WHERE','AND','=','''US Primary Ledger''',SYSDATE);
	 
INSERT INTO xx_obj_entity_inst_col_rules(obj_ent_inst_col_rule_id,obj_ent_ins_col_id,rule_type,rule_category,rule_operator,rule_desc,last_update_date) 
     VALUES (obj_ent_inst_col_rule_id_seq.nextval,67,'WHERE','AND','NOT EXISTS','(SELECT 1 FROM xx_data_pre_vld_errors WHERE error_value1=record_id)',SYSDATE);

INSERT INTO xx_obj_entity_inst_col_rules(obj_ent_inst_col_rule_id,obj_ent_ins_col_id,rule_type,rule_category,rule_desc,last_update_date) 
     VALUES (obj_ent_inst_col_rule_id_seq.nextval,46,'SELECT','DEFAULT','REFERENCE1',SYSDATE);
	 
	 
COMMIT;