--------------------
-- Program Details:
--------------------
SELECT owner, program_name, enabled FROM dba_scheduler_programs where program_name like 'XX%';

BEGIN
  DBMS_SCHEDULER.drop_program (program_name => 'XX_SYNC_GL_PERIODS_PROG');
END;

----------------
-- Schedule Job:
----------------
EXEC xx_dbms_job_pkg.sync_gl_periods_prog('FREQ=HOURLY; INTERVAL=1;');

-----------------------
-- Change Job Schedule:
-----------------------
BEGIN
  DBMS_SCHEDULER.SET_ATTRIBUTE (
   name         =>  'XX_SYNC_GL_PERIODS_JOB',
   attribute    =>  'repeat_interval',
   value        =>  'FREQ=HOURLY; INTERVAL=1;');
END;

--------------------
-- Job Status/ Logs:
--------------------
-- All jobs
SELECT * FROM dba_scheduler_jobs where job_name like 'XX%';

SELECT * FROM dba_scheduler_running_jobs;

-- Get information to job
SELECT * FROM dba_scheduler_job_log ORDER BY log_date DESC;

-- Show details on job run
SELECT * FROM dba_scheduler_job_run_details;

------------------
-- Stop/ Drop Job:
------------------
BEGIN
  -- Run job synchronously/immediately.
  /*DBMS_SCHEDULER.run_job (job_name            => 'XX_SYNC_GL_PERIODS_JOB',
                          use_current_session => TRUE); */

  -- Stop jobs.
  DBMS_SCHEDULER.stop_job (job_name => 'XX_SYNC_GL_PERIODS_JOB');
END;

BEGIN
  DBMS_SCHEDULER.drop_job (job_name => 'XX_SYNC_GL_PERIODS_JOB');
END;

-----------------------
-- Disable/Enable Jobs:
-----------------------
BEGIN
  -- Enable programs and jobs.
  DBMS_SCHEDULER.enable (name => 'XX_SYNC_GL_PERIODS_JOB');

  -- Disable programs and jobs.
  -- DBMS_SCHEDULER.disable (name => 'JOB_NAME');
END;

-------------------
-- Create Schedule:
-------------------
-- run every hour, every day
DBMS_SCHEDULER.CREATE_SCHEDULE(  
  schedule_name  => 'INTERVAL_EVERY_HOUR',  
  start_date    => trunc(sysdate)+18/24,  
  repeat_interval => 'freq=HOURLY;interval=1',  
  comments     => 'Runtime: Every day every hour'
);