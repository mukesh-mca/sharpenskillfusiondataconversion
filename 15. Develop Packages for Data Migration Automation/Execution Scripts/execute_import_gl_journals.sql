BEGIN
  xx_imp_bulk_data_in_fusion_pkg.import_gl_journals(
      p_ledger_name     => 'US Primary Ledger'
    , p_group_id        => 14099
    , p_header_required => 'N'
    , p_verbose_logging => 'Y'
  );
END;