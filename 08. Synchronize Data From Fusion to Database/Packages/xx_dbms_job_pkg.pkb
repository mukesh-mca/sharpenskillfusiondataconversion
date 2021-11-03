CREATE OR REPLACE PACKAGE BODY xx_dbms_job_pkg AS
  -- To create Program, Job on xx_sync_data_bw_fusion_db_pkg.sync_gl_periods and run at pre-defined interval
  PROCEDURE sync_gl_periods_prog(p_interval IN VARCHAR2)
  AS
    lc_prog_name      VARCHAR2(100) := 'XX_SYNC_GL_PERIODS_PROG';
	lc_program_action VARCHAR2(100) := 'xx_sync_data_bw_fusion_db_pkg.sync_gl_periods';
    lc_job_name       VARCHAR2(100) := 'XX_SYNC_GL_PERIODS_JOB';
	lb_false          BOOLEAN       := FALSE;
	lc_datetime       VARCHAR2(30);
	
  BEGIN
    
	--
	-- Create Program
	--
	DBMS_SCHEDULER.CREATE_PROGRAM(
		program_name        => lc_prog_name,
		program_action      => lc_program_action,
		program_type        => 'STORED_PROCEDURE',
		number_of_arguments => 0,
		comments            => lc_prog_name,
		enabled             => lb_false);

    DBMS_SCHEDULER.ENABLE(name=>lc_prog_name);
	
	--
	-- Create Job
	--
	lc_datetime := TO_CHAR(SYSDATE,'DDMMYYYYHH24MISS');
	--lc_job_name := lc_job_name ||'_' ||lc_datetime;
	
    DBMS_SCHEDULER.CREATE_JOB (
	   job_name        => lc_job_name,
	   program_name    => lc_prog_name,
	   start_date      => SYSTIMESTAMP,
	   repeat_interval => p_interval,-- 'FREQ=HOURLY; INTERVAL=12;',  --
	   enabled         => lb_false,
	   comments        => 'XXTRAF_GL_PERIODS_JOB');
    
	DBMS_SCHEDULER.ENABLE(name=>lc_job_name);
  END sync_gl_periods_prog;

END xx_dbms_job_pkg;
/
exit;