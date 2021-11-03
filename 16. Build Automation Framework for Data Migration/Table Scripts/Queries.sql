SELECT * FROM xx_object_entity_metadata;

SELECT * FROM xx_object_entity_instance;

SELECT * FROM xx_object_entity_instance_cols;

SELECT * FROM xx_obj_entity_inst_col_rules;

SELECT XOEIC.obj_ent_ins_col_id, XOEIC.entity_column_name, position_in_fbdi, XOEICR.rule_type,XOEICR.rule_category, XOEICR.rule_operator, XOEICR.rule_Desc 
FROM xx_obj_entity_inst_col_rules XOEICR, xx_object_entity_instance_cols XOEIC 
WHERE XOEICR.obj_ent_ins_col_id = XOEIC.obj_ent_ins_col_id;