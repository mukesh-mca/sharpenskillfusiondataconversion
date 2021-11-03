 -- +=========================================================================+
 -- |  $Header: fusionapps/fin/ap/bin/ApInvoicesInterface.ctl /st_fusionapps_pt-v2mib/14 2021/01/19 08:10:31 jenchen Exp $                                                            |
 -- +=========================================================================+
 -- |  Copyright (c) 1989 Oracle Corporation Belmont, California, USA         |
 -- |                          All rights reserved.                           |
 -- |=========================================================================+
 -- |                                                                         |
 -- |                                                                         |
 -- | FILENAME                                                                |
 -- |                                                                         |
 -- |    ApInvoicesInterface.ctl                                              |
 -- |                                                                         |
 -- | DESCRIPTION                                                             |
 -- | Control file to load Invoice data into interface table                  |
 -- +=========================================================================+

LOAD DATA
APPEND

INTO TABLE ap_invoices_interface
FIELDS TERMINATED BY "," OPTIONALLY ENCLOSED BY '"' TRAILING NULLCOLS		  
(INVOICE_ID
,OPERATING_UNIT
,SOURCE
,INVOICE_NUM
,INVOICE_AMOUNT                          "fun_load_interface_utils_pkg.replace_decimal_char(:INVOICE_AMOUNT)" 
,INVOICE_DATE                            "TO_DATE(:INVOICE_DATE, 'YYYY/MM/DD')"
,VENDOR_NAME
,VENDOR_NUM
,VENDOR_SITE_CODE
,INVOICE_CURRENCY_CODE
,PAYMENT_CURRENCY_CODE
,DESCRIPTION                             CHAR(240) "REPLACE(:DESCRIPTION, '\\n','\n')"
,GROUP_ID
,INVOICE_TYPE_LOOKUP_CODE
,LEGAL_ENTITY_NAME
,CUST_REGISTRATION_NUMBER
,CUST_REGISTRATION_CODE
,FIRST_PARTY_REGISTRATION_NUM
,THIRD_PARTY_REGISTRATION_NUM
,TERMS_NAME
,TERMS_DATE                              "TO_DATE(:TERMS_DATE, 'YYYY/MM/DD')" 
,GOODS_RECEIVED_DATE                     "TO_DATE(:GOODS_RECEIVED_DATE, 'YYYY/MM/DD')" 
,INVOICE_RECEIVED_DATE                   "TO_DATE(:INVOICE_RECEIVED_DATE, 'YYYY/MM/DD')" 
,GL_DATE                                 "TO_DATE(:GL_DATE, 'YYYY/MM/DD')" 
,PAYMENT_METHOD_CODE
,PAY_GROUP_LOOKUP_CODE                   "fun_load_interface_utils_pkg.check_null_char(:PAY_GROUP_LOOKUP_CODE)" 
,EXCLUSIVE_PAYMENT_FLAG                  "fun_load_interface_utils_pkg.check_null_char(:EXCLUSIVE_PAYMENT_FLAG)" 
,AMOUNT_APPLICABLE_TO_DISCOUNT           "fun_load_interface_utils_pkg.replace_decimal_char(:AMOUNT_APPLICABLE_TO_DISCOUNT)"
,PREPAY_NUM
,PREPAY_LINE_NUM                         "fun_load_interface_utils_pkg.replace_decimal_char(:PREPAY_LINE_NUM)"
,PREPAY_APPLY_AMOUNT                     "fun_load_interface_utils_pkg.replace_decimal_char(:PREPAY_APPLY_AMOUNT)"
,PREPAY_GL_DATE                          "TO_DATE(:PREPAY_GL_DATE, 'YYYY/MM/DD')"
,INVOICE_INCLUDES_PREPAY_FLAG
,EXCHANGE_RATE_TYPE
,EXCHANGE_DATE                           "TO_DATE(:EXCHANGE_DATE, 'YYYY/MM/DD')" 
,EXCHANGE_RATE                           "fun_load_interface_utils_pkg.replace_decimal_char(:EXCHANGE_RATE)"
,ACCTS_PAY_CODE_CONCATENATED
,DOC_CATEGORY_CODE                       "fun_load_interface_utils_pkg.check_null_char(:DOC_CATEGORY_CODE)" 
,VOUCHER_NUM
,REQUESTER_FIRST_NAME
,REQUESTER_LAST_NAME
,REQUESTER_EMPLOYEE_NUM
,DELIVERY_CHANNEL_CODE                   "fun_load_interface_utils_pkg.check_null_char(:DELIVERY_CHANNEL_CODE)" 
,BANK_CHARGE_BEARER                      "fun_load_interface_utils_pkg.check_null_char(:BANK_CHARGE_BEARER)" 
,REMIT_TO_SUPPLIER_NAME                  "fun_load_interface_utils_pkg.check_null_char(:REMIT_TO_SUPPLIER_NAME)" 
,REMIT_TO_SUPPLIER_NUM                   "fun_load_interface_utils_pkg.check_null_char(:REMIT_TO_SUPPLIER_NUM)" 
,REMIT_TO_ADDRESS_NAME                   "fun_load_interface_utils_pkg.check_null_char(:REMIT_TO_ADDRESS_NAME)"    
,PAYMENT_PRIORITY                        "fun_load_interface_utils_pkg.replace_decimal_char(:PAYMENT_PRIORITY)"
,SETTLEMENT_PRIORITY                     "fun_load_interface_utils_pkg.check_null_char(:SETTLEMENT_PRIORITY)" 
,UNIQUE_REMITTANCE_IDENTIFIER		  CHAR(256)
,URI_CHECK_DIGIT
,PAYMENT_REASON_CODE                     "fun_load_interface_utils_pkg.check_null_char(:PAYMENT_REASON_CODE)"
,PAYMENT_REASON_COMMENTS                 "fun_load_interface_utils_pkg.check_null_char(REPLACE(:PAYMENT_REASON_COMMENTS, '\\n','\n'))"
,REMITTANCE_MESSAGE1                     "REPLACE(:REMITTANCE_MESSAGE1, '\\n','\n')"
,REMITTANCE_MESSAGE2                     "REPLACE(:REMITTANCE_MESSAGE2, '\\n','\n')"
,REMITTANCE_MESSAGE3                     "REPLACE(:REMITTANCE_MESSAGE3, '\\n','\n')"
,AWT_GROUP_NAME                          "fun_load_interface_utils_pkg.check_null_char(:AWT_GROUP_NAME)"    
,SHIP_TO_LOCATION
,TAXATION_COUNTRY                        "fun_load_interface_utils_pkg.check_null_char(:TAXATION_COUNTRY)" 
,DOCUMENT_SUB_TYPE
,TAX_INVOICE_INTERNAL_SEQ
,SUPPLIER_TAX_INVOICE_NUMBER
,TAX_INVOICE_RECORDING_DATE              "TO_DATE(:TAX_INVOICE_RECORDING_DATE, 'YYYY/MM/DD')"
,SUPPLIER_TAX_INVOICE_DATE               "TO_DATE(:SUPPLIER_TAX_INVOICE_DATE, 'YYYY/MM/DD')"
,SUPPLIER_TAX_EXCHANGE_RATE              "fun_load_interface_utils_pkg.replace_decimal_char(:SUPPLIER_TAX_EXCHANGE_RATE)"
,PORT_OF_ENTRY_CODE
,CORRECTION_YEAR                         "fun_load_interface_utils_pkg.replace_decimal_char(:CORRECTION_YEAR)"
,CORRECTION_PERIOD
,IMPORT_DOCUMENT_NUMBER
,IMPORT_DOCUMENT_DATE                    "TO_DATE(:IMPORT_DOCUMENT_DATE, 'YYYY/MM/DD')" 
,CONTROL_AMOUNT                          "fun_load_interface_utils_pkg.replace_decimal_char(:CONTROL_AMOUNT)"
,CALC_TAX_DURING_IMPORT_FLAG
,ADD_TAX_TO_INV_AMT_FLAG
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
,ATTRIBUTE15                             CHAR(1000) "REPLACE(:ATTRIBUTE15, '\\n','\n')"
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
,IMAGE_DOCUMENT_URI                      CHAR(4000)
,EXTERNAL_BANK_ACCOUNT_NUMBER            "fun_load_interface_utils_pkg.check_null_char(:EXTERNAL_BANK_ACCOUNT_NUMBER)"
,EXT_BANK_ACCOUNT_IBAN_NUMBER            "fun_load_interface_utils_pkg.check_null_char(:EXT_BANK_ACCOUNT_IBAN_NUMBER)"
,REQUESTER_EMAIL_ADDRESS                 CHAR(240) 
,LAST_UPDATE_DATE                        expression "systimestamp" 
,LAST_UPDATED_BY                         constant '#LASTUPDATEDBY#' 
,LAST_UPDATE_LOGIN                       constant '#LASTUPDATELOGIN#' 
,CREATION_DATE                           expression "systimestamp" 
,CREATED_BY                              constant '#CREATEDBY#' 
,OBJECT_VERSION_NUMBER                   constant  1
,LOAD_REQUEST_ID                         constant  '#LOADREQUESTID#'
)
