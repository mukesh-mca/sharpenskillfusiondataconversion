SELECT DISTINCT
    glp.period_name      AS period_name,
    gl.name              AS ledger_name,
    gps.closing_status   AS status,
    TO_CHAR(sysdate,'DD-MM-YYYY')             last_update_date
FROM
    fusion.gl_periods           glp,
    fusion.gl_period_statuses   gps,
    fusion.gl_ledgers           gl,
    fnd_application fa
WHERE
    gl.ledger_id = gps.ledger_id
    AND gps.period_name = glp.period_name
    AND gl.ledger_category_code = 'PRIMARY'
    AND gps.application_id = fa.application_id
    AND fa.application_short_name = 'GL'