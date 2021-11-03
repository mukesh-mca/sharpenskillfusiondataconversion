BEGIN
  dbms_output.put_line('Start Here..');
  xx_sync_data_bw_fusion_db_pkg.sync_gl_periods();
  dbms_output.put_line('Table is in sync with Fusion');
EXCEPTION
  WHEN OTHERS
  THEN
    dbms_output.put_line('Error here:'||substr(sqlerrm,1,200));
END;