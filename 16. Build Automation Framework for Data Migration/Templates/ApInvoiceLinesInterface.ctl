 -- +=========================================================================+
 -- |  $Header: fusionapps/fin/ap/bin/ApInvoiceLinesInterface.ctl /st_fusionapps_pt-v2mib/12 2021/01/19 08:10:31 jenchen Exp $                                                            |
 -- +=========================================================================+
 -- |  Copyright (c) 1989 Oracle Corporation Belmont, California, USA         |
 -- |                          All rights reserved.                           |
 -- |=========================================================================+
 -- |                                                                         |
 -- |                                                                         |
 -- | FILENAME                                                                |
 -- |                                                                         |
 -- |    ApInvoiceLinesInterface.ctl                                          |
 -- |                                                                         |
 -- | DESCRIPTION                                                             |
 -- |  Control file to load Invoice Lines data into interface table           |
 -- +=========================================================================+

LOAD DATA
APPEND

INTO TABLE ap_invoice_lines_interface
FIELDS TERMINATED BY "," OPTIONALLY ENCLOSED BY '"' TRAILING NULLCOLS
(INVOICE_ID                              
,INVOICE_LINE_ID                         expression "AP_INVOICE_LINES_INTERFACE_S.NEXTVAL"             
,LINE_NUMBER                             "fun_load_interface_utils_pkg.replace_decimal_char(:LINE_NUMBER)"
,LINE_TYPE_LOOKUP_CODE
,AMOUNT                                  "fun_load_interface_utils_pkg.replace_decimal_char(:AMOUNT)"
,QUANTITY_INVOICED                       "fun_load_interface_utils_pkg.replace_decimal_char(:QUANTITY_INVOICED)"
,UNIT_PRICE                              "fun_load_interface_utils_pkg.replace_decimal_char(:UNIT_PRICE)"
,UNIT_OF_MEAS_LOOKUP_CODE
,DESCRIPTION                             "REPLACE(:DESCRIPTION,'\\n','\n')"
,PO_NUMBER
,PO_LINE_NUMBER                          "fun_load_interface_utils_pkg.replace_decimal_char(:PO_LINE_NUMBER)"
,PO_SHIPMENT_NUM                         "fun_load_interface_utils_pkg.replace_decimal_char(:PO_SHIPMENT_NUM)"
,PO_DISTRIBUTION_NUM                     "fun_load_interface_utils_pkg.replace_decimal_char(:PO_DISTRIBUTION_NUM)"
,ITEM_DESCRIPTION                        "REPLACE(:ITEM_DESCRIPTION,'\\n','\n')"
,RELEASE_NUM                             "fun_load_interface_utils_pkg.replace_decimal_char(:RELEASE_NUM)"
,PURCHASING_CATEGORY                     CHAR(2000) "REPLACE(:PURCHASING_CATEGORY,'\\n','\n')"
,RECEIPT_NUMBER
,RECEIPT_LINE_NUMBER
,CONSUMPTION_ADVICE_NUMBER
,CONSUMPTION_ADVICE_LINE_NUMBER          "fun_load_interface_utils_pkg.replace_decimal_char(:CONSUMPTION_ADVICE_LINE_NUMBER)"
,PACKING_SLIP
,FINAL_MATCH_FLAG
,DIST_CODE_CONCATENATED
,DISTRIBUTION_SET_NAME                   "fun_load_interface_utils_pkg.check_null_char(:DISTRIBUTION_SET_NAME)"    
,ACCOUNTING_DATE                         "TO_DATE(:ACCOUNTING_DATE, 'YYYY/MM/DD')"
,ACCOUNT_SEGMENT
,BALANCING_SEGMENT
,COST_CENTER_SEGMENT
,TAX_CLASSIFICATION_CODE                 
,SHIP_TO_LOCATION_CODE                   "fun_load_interface_utils_pkg.check_null_char(:SHIP_TO_LOCATION_CODE)"            
,SHIP_FROM_LOCATION_CODE
,FINAL_DISCHARGE_LOCATION_CODE
,TRX_BUSINESS_CATEGORY                   
,PRODUCT_FISC_CLASSIFICATION             
,PRIMARY_INTENDED_USE                    
,USER_DEFINED_FISC_CLASS                 
,PRODUCT_TYPE                            
,ASSESSABLE_VALUE                        "fun_load_interface_utils_pkg.replace_decimal_char(:ASSESSABLE_VALUE)"
,PRODUCT_CATEGORY                        
,CONTROL_AMOUNT                          "fun_load_interface_utils_pkg.replace_decimal_char(:CONTROL_AMOUNT)"
,TAX_REGIME_CODE
,TAX
,TAX_STATUS_CODE
,TAX_JURISDICTION_CODE
,TAX_RATE_CODE
,TAX_RATE                                "fun_load_interface_utils_pkg.replace_decimal_char(:TAX_RATE)"
,AWT_GROUP_NAME                          "fun_load_interface_utils_pkg.check_null_char(:AWT_GROUP_NAME)"    
,TYPE_1099
,INCOME_TAX_REGION
,PRORATE_ACROSS_FLAG
,LINE_GROUP_NUMBER                       "fun_load_interface_utils_pkg.replace_decimal_char(:LINE_GROUP_NUMBER)"
,COST_FACTOR_NAME
,STAT_AMOUNT                             "fun_load_interface_utils_pkg.replace_decimal_char(:STAT_AMOUNT)"
,ASSETS_TRACKING_FLAG
,ASSET_BOOK_TYPE_CODE
,ASSET_CATEGORY_ID
,SERIAL_NUMBER
,MANUFACTURER
,MODEL_NUMBER
,WARRANTY_NUMBER
,PRICE_CORRECTION_FLAG
,PRICE_CORRECT_INV_NUM
,PRICE_CORRECT_INV_LINE_NUM              "fun_load_interface_utils_pkg.replace_decimal_char(:PRICE_CORRECT_INV_LINE_NUM)"
,REQUESTER_FIRST_NAME
,REQUESTER_LAST_NAME
,REQUESTER_EMPLOYEE_NUM
,ATTRIBUTE_CATEGORY                      "REPLACE(:ATTRIBUTE_CATEGORY, '\\n','\n')"
,ATTRIBUTE1                              "REPLACE(:ATTRIBUTE1, '\\n','\n')"
,ATTRIBUTE2                              "REPLACE(:ATTRIBUTE2, '\\n','\n')"
,ATTRIBUTE3                              "REPLACE(:ATTRIBUTE3, '\\n','\n')"
,ATTRIBUTE4                              "REPLACE(:ATTRIBUTE4, '\\n','\n')"
,ATTRIBUTE5                              "REPLACE(:ATTRIBUTE5, '\\n','\n')"
,ATTRIBUTE6                              "REPLACE(:ATTRIBUTE6, '\\n','\n')"
,ATTRIBUTE7                              "REPLACE(:ATTRIBUTE7, '\\n','\n')"
,ATTRIBUTE8                              "REPLACE(:ATTRIBUTE8, '\\n','\n')"
,ATTRIBUTE9                              "REPLACE(:ATTRIBUTE9, '\\n','\n')"
,ATTRIBUTE10                             "REPLACE(:ATTRIBUTE10, '\\n','\n')"
,ATTRIBUTE11                             "REPLACE(:ATTRIBUTE11, '\\n','\n')"
,ATTRIBUTE12                             "REPLACE(:ATTRIBUTE12, '\\n','\n')"
,ATTRIBUTE13                             "REPLACE(:ATTRIBUTE13, '\\n','\n')"
,ATTRIBUTE14                             "REPLACE(:ATTRIBUTE14, '\\n','\n')"
,ATTRIBUTE15                             "REPLACE(:ATTRIBUTE15, '\\n','\n')"
,ATTRIBUTE_NUMBER1                       "fun_load_interface_utils_pkg.replace_decimal_char(:ATTRIBUTE_NUMBER1)" 
,ATTRIBUTE_NUMBER2                       "fun_load_interface_utils_pkg.replace_decimal_char(:ATTRIBUTE_NUMBER2)"  
,ATTRIBUTE_NUMBER3                       "fun_load_interface_utils_pkg.replace_decimal_char(:ATTRIBUTE_NUMBER3)"  
,ATTRIBUTE_NUMBER4                       "fun_load_interface_utils_pkg.replace_decimal_char(:ATTRIBUTE_NUMBER4)"  
,ATTRIBUTE_NUMBER5                       "fun_load_interface_utils_pkg.replace_decimal_char(:ATTRIBUTE_NUMBER5)" 
,ATTRIBUTE_DATE1                         "TO_DATE(:ATTRIBUTE_DATE1, 'YYYY/MM/DD')" 
,ATTRIBUTE_DATE2                         "TO_DATE(:ATTRIBUTE_DATE2, 'YYYY/MM/DD')" 
,ATTRIBUTE_DATE3                         "TO_DATE(:ATTRIBUTE_DATE3, 'YYYY/MM/DD')" 
,ATTRIBUTE_DATE4                         "TO_DATE(:ATTRIBUTE_DATE4, 'YYYY/MM/DD')" 
,ATTRIBUTE_DATE5                         "TO_DATE(:ATTRIBUTE_DATE5, 'YYYY/MM/DD')"
,GLOBAL_ATTRIBUTE_CATEGORY               "REPLACE(:GLOBAL_ATTRIBUTE_CATEGORY, '\\n','\n')"
,GLOBAL_ATTRIBUTE1                       "REPLACE(:GLOBAL_ATTRIBUTE1, '\\n','\n')"
,GLOBAL_ATTRIBUTE2                       "REPLACE(:GLOBAL_ATTRIBUTE2, '\\n','\n')"
,GLOBAL_ATTRIBUTE3                       "REPLACE(:GLOBAL_ATTRIBUTE3, '\\n','\n')"
,GLOBAL_ATTRIBUTE4                       "REPLACE(:GLOBAL_ATTRIBUTE4, '\\n','\n')"
,GLOBAL_ATTRIBUTE5                       "REPLACE(:GLOBAL_ATTRIBUTE5, '\\n','\n')"
,GLOBAL_ATTRIBUTE6                       "REPLACE(:GLOBAL_ATTRIBUTE6, '\\n','\n')"
,GLOBAL_ATTRIBUTE7                       "REPLACE(:GLOBAL_ATTRIBUTE7, '\\n','\n')"
,GLOBAL_ATTRIBUTE8                       "REPLACE(:GLOBAL_ATTRIBUTE8, '\\n','\n')"
,GLOBAL_ATTRIBUTE9                       "REPLACE(:GLOBAL_ATTRIBUTE9, '\\n','\n')"
,GLOBAL_ATTRIBUTE10                      "REPLACE(:GLOBAL_ATTRIBUTE10, '\\n','\n')"
,GLOBAL_ATTRIBUTE11                      "REPLACE(:GLOBAL_ATTRIBUTE11, '\\n','\n')"
,GLOBAL_ATTRIBUTE12                      "REPLACE(:GLOBAL_ATTRIBUTE12, '\\n','\n')"
,GLOBAL_ATTRIBUTE13                      "REPLACE(:GLOBAL_ATTRIBUTE13, '\\n','\n')"
,GLOBAL_ATTRIBUTE14                      "REPLACE(:GLOBAL_ATTRIBUTE14, '\\n','\n')"
,GLOBAL_ATTRIBUTE15                      "REPLACE(:GLOBAL_ATTRIBUTE15, '\\n','\n')"
,GLOBAL_ATTRIBUTE16                      "REPLACE(:GLOBAL_ATTRIBUTE16, '\\n','\n')"
,GLOBAL_ATTRIBUTE17                      "REPLACE(:GLOBAL_ATTRIBUTE17, '\\n','\n')"
,GLOBAL_ATTRIBUTE18                      "REPLACE(:GLOBAL_ATTRIBUTE18, '\\n','\n')"
,GLOBAL_ATTRIBUTE19                      "REPLACE(:GLOBAL_ATTRIBUTE19, '\\n','\n')"
,GLOBAL_ATTRIBUTE20                      "REPLACE(:GLOBAL_ATTRIBUTE20, '\\n','\n')"
,GLOBAL_ATTRIBUTE_NUMBER1                "fun_load_interface_utils_pkg.replace_decimal_char(:GLOBAL_ATTRIBUTE_NUMBER1)" 
,GLOBAL_ATTRIBUTE_NUMBER2                "fun_load_interface_utils_pkg.replace_decimal_char(:GLOBAL_ATTRIBUTE_NUMBER2)"  
,GLOBAL_ATTRIBUTE_NUMBER3                "fun_load_interface_utils_pkg.replace_decimal_char(:GLOBAL_ATTRIBUTE_NUMBER3)"  
,GLOBAL_ATTRIBUTE_NUMBER4                "fun_load_interface_utils_pkg.replace_decimal_char(:GLOBAL_ATTRIBUTE_NUMBER4)"  
,GLOBAL_ATTRIBUTE_NUMBER5                "fun_load_interface_utils_pkg.replace_decimal_char(:GLOBAL_ATTRIBUTE_NUMBER5)"  
,GLOBAL_ATTRIBUTE_DATE1                  "TO_DATE(:GLOBAL_ATTRIBUTE_DATE1, 'YYYY/MM/DD')" 
,GLOBAL_ATTRIBUTE_DATE2                  "TO_DATE(:GLOBAL_ATTRIBUTE_DATE2, 'YYYY/MM/DD')" 
,GLOBAL_ATTRIBUTE_DATE3                  "TO_DATE(:GLOBAL_ATTRIBUTE_DATE3, 'YYYY/MM/DD')" 
,GLOBAL_ATTRIBUTE_DATE4                  "TO_DATE(:GLOBAL_ATTRIBUTE_DATE4, 'YYYY/MM/DD')" 
,GLOBAL_ATTRIBUTE_DATE5                  "TO_DATE(:GLOBAL_ATTRIBUTE_DATE5, 'YYYY/MM/DD')"
,PJC_PROJECT_ID
,PJC_TASK_ID
,PJC_EXPENDITURE_TYPE_ID
,PJC_EXPENDITURE_ITEM_DATE               "TO_DATE(:PJC_EXPENDITURE_ITEM_DATE, 'YYYY/MM/DD')"
,PJC_ORGANIZATION_ID
,PJC_PROJECT_NUMBER
,PJC_TASK_NUMBER
,PJC_EXPENDITURE_TYPE_NAME
,PJC_ORGANIZATION_NAME
,PJC_RESERVED_ATTRIBUTE1                 "CASE WHEN :PJC_RESERVED_ATTRIBUTE1 like 'END_' THEN NULL  ELSE REPLACE(:PJC_RESERVED_ATTRIBUTE1, '\\n','\n') END"
,PJC_RESERVED_ATTRIBUTE2                 "REPLACE(:PJC_RESERVED_ATTRIBUTE2, '\\n','\n')"
,PJC_RESERVED_ATTRIBUTE3                 "REPLACE(:PJC_RESERVED_ATTRIBUTE3, '\\n','\n')"
,PJC_RESERVED_ATTRIBUTE4                 "REPLACE(:PJC_RESERVED_ATTRIBUTE4, '\\n','\n')"
,PJC_RESERVED_ATTRIBUTE5                 "REPLACE(:PJC_RESERVED_ATTRIBUTE5, '\\n','\n')"
,PJC_RESERVED_ATTRIBUTE6                 "REPLACE(:PJC_RESERVED_ATTRIBUTE6, '\\n','\n')"
,PJC_RESERVED_ATTRIBUTE7                 "REPLACE(:PJC_RESERVED_ATTRIBUTE7, '\\n','\n')"
,PJC_RESERVED_ATTRIBUTE8                 "REPLACE(:PJC_RESERVED_ATTRIBUTE8, '\\n','\n')"
,PJC_RESERVED_ATTRIBUTE9                 "REPLACE(:PJC_RESERVED_ATTRIBUTE9, '\\n','\n')"
,PJC_RESERVED_ATTRIBUTE10                "REPLACE(:PJC_RESERVED_ATTRIBUTE10, '\\n','\n')"
,PJC_USER_DEF_ATTRIBUTE1                 "REPLACE(:PJC_USER_DEF_ATTRIBUTE1, '\\n','\n')"
,PJC_USER_DEF_ATTRIBUTE2                 "REPLACE(:PJC_USER_DEF_ATTRIBUTE2, '\\n','\n')"
,PJC_USER_DEF_ATTRIBUTE3                 "REPLACE(:PJC_USER_DEF_ATTRIBUTE3, '\\n','\n')"
,PJC_USER_DEF_ATTRIBUTE4                 "REPLACE(:PJC_USER_DEF_ATTRIBUTE4, '\\n','\n')"
,PJC_USER_DEF_ATTRIBUTE5                 "REPLACE(:PJC_USER_DEF_ATTRIBUTE5, '\\n','\n')"
,PJC_USER_DEF_ATTRIBUTE6                 "REPLACE(:PJC_USER_DEF_ATTRIBUTE6, '\\n','\n')"
,PJC_USER_DEF_ATTRIBUTE7                 "REPLACE(:PJC_USER_DEF_ATTRIBUTE7, '\\n','\n')"
,PJC_USER_DEF_ATTRIBUTE8                 "REPLACE(:PJC_USER_DEF_ATTRIBUTE8, '\\n','\n')"
,PJC_USER_DEF_ATTRIBUTE9                 "REPLACE(:PJC_USER_DEF_ATTRIBUTE9, '\\n','\n')"
,PJC_USER_DEF_ATTRIBUTE10                "REPLACE(:PJC_USER_DEF_ATTRIBUTE10, '\\n','\n')"
,FISCAL_CHARGE_TYPE                      "CASE WHEN :FISCAL_CHARGE_TYPE like 'END_' THEN NULL  ELSE :FISCAL_CHARGE_TYPE END"
,DEF_ACCTG_START_DATE                    "CASE WHEN :DEF_ACCTG_START_DATE like 'END_' THEN NULL ELSE TO_DATE(:DEF_ACCTG_START_DATE, 'YYYY/MM/DD') END"
,DEF_ACCTG_END_DATE                      "CASE WHEN :DEF_ACCTG_END_DATE like 'END_' THEN NULL ELSE TO_DATE(:DEF_ACCTG_END_DATE, 'YYYY/MM/DD') END"
,DEF_ACCRUAL_CODE_CONCATENATED           CHAR(800) "CASE WHEN :DEF_ACCRUAL_CODE_CONCATENATED like 'END_' THEN NULL  ELSE :DEF_ACCRUAL_CODE_CONCATENATED END"
,PJC_PROJECT_NAME                        "CASE WHEN :PJC_PROJECT_NAME like 'END_' THEN NULL  ELSE :PJC_PROJECT_NAME END"
,PJC_TASK_NAME                           "CASE WHEN :PJC_TASK_NAME like 'END_' THEN NULL  ELSE :PJC_TASK_NAME END"
,PJC_WORK_TYPE                           "CASE WHEN :PJC_WORK_TYPE like 'END_' THEN NULL  ELSE :PJC_WORK_TYPE END"
,PJC_CONTRACT_NAME                       CHAR(300) "CASE WHEN :PJC_CONTRACT_NAME like 'END_' THEN NULL  ELSE :PJC_CONTRACT_NAME END"
,PJC_CONTRACT_NUMBER                     "CASE WHEN :PJC_CONTRACT_NUMBER like 'END_' THEN NULL  ELSE :PJC_CONTRACT_NUMBER END"
,PJC_FUNDING_SOURCE_NAME                 CHAR(360) "CASE WHEN :PJC_FUNDING_SOURCE_NAME like 'END_' THEN NULL  ELSE :PJC_FUNDING_SOURCE_NAME END"
,PJC_FUNDING_SOURCE_NUMBER               "CASE WHEN :PJC_FUNDING_SOURCE_NUMBER like 'END_' THEN NULL  ELSE :PJC_FUNDING_SOURCE_NUMBER END"
,REQUESTER_EMAIL_ADDRESS                 CHAR(240) 
,LAST_UPDATE_DATE                        expression "systimestamp" 
,LAST_UPDATED_BY                         constant '#LASTUPDATEDBY#' 
,LAST_UPDATE_LOGIN                       constant '#LASTUPDATELOGIN#' 
,CREATION_DATE                           expression "systimestamp" 
,CREATED_BY                              constant '#CREATEDBY#' 
,OBJECT_VERSION_NUMBER                   constant 1
,LOAD_REQUEST_ID                         constant '#LOADREQUESTID#'
)
