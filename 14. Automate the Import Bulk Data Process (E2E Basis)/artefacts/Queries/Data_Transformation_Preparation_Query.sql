SELECT
    'NEW' status,
    (
        SELECT
            ledger_id
        FROM
            xx_gl_ledger_das_lookup
        WHERE
            ledger_name = 'US Primary Ledger'
    ) ledger_id,
    accounting_date,
    'Spreadsheet' user_je_source_name,
    'Miscellaneous' user_je_category_name,
    currency_code,
    date_created,
    'A' actual_flag,
    segment1,
    segment2,
    segment3,
    segment4,
    segment5,
    segment6,
    segment7,
    segment8,
    segment9,
    segment10,
    segment11,
    segment12,
    segment13,
    segment14,
    segment15,
    segment16,
    segment17,
    segment18,
    segment19,
    segment20,
    segment21,
    segment22,
    segment23,
    segment24,
    segment25,
    segment26,
    segment27,
    segment28,
    segment29,
    segment30,
    entered_dr,
    entered_cr,
    accounted_dr,
    accounted_cr,
    reference1,
    reference2,
    reference3,
    reference1   reference4,
    reference5,
    reference6,
    reference7,
    reference8,
    reference9,
    reference10,
    reference21,
    reference22,
    reference23,
    reference24,
    reference25,
    reference26,
    reference27,
    reference28,
    reference29,
    reference30,
    stat_amount,
    user_currency_conversion_type,
    currency_conversion_date,
    currency_conversion_rate,
    group_id,
    attribute_category,
    attribute1,
    attribute2,
    attribute3,
    attribute4,
    attribute5,
    attribute6,
    attribute7,
    attribute8,
    attribute9,
    attribute10,
    attribute11,
    attribute12,
    attribute13,
    attribute14,
    attribute15,
    attribute16,
    attribute17,
    attribute18,
    attribute19,
    attribute20,
    attribute_category3,
    average_journal_flag,
    originating_bal_seg_value,
    ledger_name,
    encumbrance_type_id,
    jgzz_recon_ref,
    period_name,
    reference18,
    reference19,
    reference20,
    attribute_date1,
    attribute_date2,
    attribute_date3,
    attribute_date4,
    attribute_date5,
    attribute_date6,
    attribute_date7,
    attribute_date8,
    attribute_date9,
    attribute_date10,
    attribute_number1,
    attribute_number2,
    attribute_number3,
    attribute_number4,
    attribute_number5,
    attribute_number6,
    attribute_number7,
    attribute_number8,
    attribute_number9,
    attribute_number10,
    global_attribute_category,
    global_attribute1,
    global_attribute2,
    global_attribute3,
    global_attribute4,
    global_attribute5,
    global_attribute6,
    global_attribute7,
    global_attribute8,
    global_attribute9,
    global_attribute10,
    global_attribute11,
    global_attribute12,
    global_attribute13,
    global_attribute14,
    global_attribute15,
    global_attribute16,
    global_attribute17,
    global_attribute18,
    global_attribute19,
    global_attribute20,
    global_attribute_date1,
    global_attribute_date2,
    global_attribute_date3,
    global_attribute_date4,
    global_attribute_date5,
    global_attribute_number1,
    global_attribute_number2,
    global_attribute_number3,
    global_attribute_number4,
    global_attribute_number5
FROM
    gl_interface_stg
WHERE
    1 = 1
    AND NOT EXISTS (
        SELECT
            1
        FROM
            xx_data_pre_vld_errors
        WHERE
            error_value1 = record_id
    )
    AND ledger_name = 'US Primary Ledger';