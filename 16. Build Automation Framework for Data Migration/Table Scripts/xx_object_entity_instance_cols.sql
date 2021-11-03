CREATE TABLE xx_object_entity_instance_cols(
    obj_ent_ins_col_id  NUMBER
  , object_instance_id  NUMBER
  , entity_column_name  VARCHAR2(100)
  , position_in_fbdi    NUMBER
  , include_in_fbdi     VARCHAR2(1)
  , last_update_date    DATE
);

CREATE SEQUENCE xx_obj_ent_ins_col_id_seq START WITH 1 INCREMENT BY 1;

DECLARE
  ln_count NUMBER := 0;
  lc_obj_instance VARCHAR2(100) := 'JournalImport_US';
  lc_owner  VARCHAR2(50) := 'ADB_USER';
  
  CURSOR lcu_get_columns(p_stg_table_name VARCHAR2)
  IS
    SELECT column_name
	  FROM all_tab_columns
	 WHERE table_name = p_stg_table_name
	   AND owner = lc_owner
	   AND column_name NOT IN ('DATA_LOAD_DATE','RECORD_ID')
	 ORDER BY column_id;
	 
  CURSOR lcu_get_obj_instance_dtls(p_object_instance VARCHAR2)
  IS
    SELECT   object_instance_id
	       , entity_stg_table
	  FROM   xx_object_entity_instance XOEI
	       , xx_object_entity_metadata XOEM
	 WHERE   XOEM.entity_id = XOEI.entity_id
	   AND   XOEI.entity_active_flag = 'Y'
	   AND   object_instance = p_object_instance;
BEGIN
  FOR i IN lcu_get_obj_instance_dtls(lc_obj_instance)
  LOOP
    FOR j IN lcu_get_columns(i.entity_stg_table)
	LOOP
      ln_count := ln_count+5;
      INSERT INTO xx_object_entity_instance_cols(obj_ent_ins_col_id,object_instance_id,entity_column_name,position_in_fbdi,include_in_fbdi,last_update_date)
           VALUES (xx_obj_ent_ins_col_id_seq.nextval,i.object_instance_id,j.column_name,ln_count,'Y',SYSDATE);
	END LOOP;
  END LOOP;
  COMMIT;
END;