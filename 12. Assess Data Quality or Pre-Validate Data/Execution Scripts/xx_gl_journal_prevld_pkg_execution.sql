DECLARE
  lc_ledger_name  VARCHAR2(100) := 'US Primary Ledger';
  ln_succ_rec_cnt NUMBER;
BEGIN
  xx_gl_journal_prevld_pkg.validate_gl_journals(p_ledger_name => lc_ledger_name, o_succ_rec_cnt => ln_succ_rec_cnt);
  dbms_output.put_line('ln_succ_rec_cnt='||ln_succ_rec_cnt);
END;