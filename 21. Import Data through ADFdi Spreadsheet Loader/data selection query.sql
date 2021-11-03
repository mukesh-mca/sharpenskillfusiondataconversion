SELECT   from_currency_code 
       , to_currency_code
       , conversion_rate
       , TO_CHAR(from_conversion_date,'MM/DD/YYYY')
       , TO_CHAR(to_conversion_date,'MM/DD/YYYY')
       , conversion_rate
       , inverse_rate
  FROM   gl_daily_rates_stg;  