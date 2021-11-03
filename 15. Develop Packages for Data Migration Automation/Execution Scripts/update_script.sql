UPDATE gl_interface_stg set group_id = 14099, reference1 = 'DEMOBATCH'||'14099';
UPDATE gl_interface_stg set accounting_date = to_date('2021/08/29','YYYY/MM/DD'), date_created = to_date('2021/08/29','YYYY/MM/DD')
 WHERE to_char(accounting_date,'YYYY') > 2000;
COMMIT;