view: clustdoc_vendor_sync_ts {
  derived_table: {
    sql: SELECT CVA.VENDOR_PORTAL_ID                                                     AS APPLICATION_NUMBER,
       CVA.COMPANY                                                              AS COMPANY_NAME,
       CVA.LEGAL_NAME                                                           AS LEGAL,
       CASE
           WHEN CVA.ACH_ROUT_NUM != CVA.ACH_ROUT_NUM_2 AND cva.VENDOR_PORTAL_ID >= 20404275
               THEN 'Routing Numbers do not match'
           ELSE '-' END                                                         AS ROUT_NUM_CHECK,
       CASE
           WHEN CVA.BANK_ACCT_NUM != CVA.BANK_ACCT_NUM_2 AND cva.VENDOR_PORTAL_ID >= 20404275
               THEN 'Bank Acct Numbers do not match'
           ELSE '-' END                                                         AS BANK_ACCT_NUM_CHECK,
       CASE
           WHEN LENGTH(CVA.TAX_ID) NOT IN (10, 11) THEN 'Tax ID length is incorrect'
           ELSE '-' END                                                         AS TAX_ID_LENGTH,
       CASE
           WHEN CVA.TAX_ID != TRIM(CVA.TAX_ID) THEN 'Tax ID has a space at beginning or end'
           ELSE '-' END                                                         AS TAX_ID_TRIM,
       CASE
           WHEN (SUBSTR(CVA.TAX_ID, 3, 1) = '-' OR (SUBSTR(CVA.TAX_ID, 4, 1) = '-' AND SUBSTR(CVA.TAX_ID, 7, 1) = '-'))
               THEN '-'
           ELSE 'Tax ID is missing hyphen in correct space/s' END               AS TAX_ID_HYPHEN,
       CASE
           WHEN LENGTH(CVA.ACH_ROUT_NUM) NOT IN (9) AND (CVA.ACH_ROUT_NUM IS NOT NULL AND TRIM(CVA.ACH_ROUT_NUM) != '')
               THEN 'Routing number is not 9 characters'
           ELSE '-' END                                                         AS ROUTING_LENGTH,
       CASE
           WHEN LENGTH(CVA.PHONE) > 25 OR LENGTH(CVA.PRIMARY_PHONE) > 25 OR LENGTH(CVA.AR_PHONE) > 25
               THEN 'One phone number is more than 25 characters'
           ELSE '-' END                                                         AS PHONE_LENGTH,
       CASE
           WHEN
               ((REGEXP_COUNT(CVA.PRIMARY_EMAIL, '@') = 1) OR CVA.PRIMARY_EMAIL IS NULL OR TRIM(CVA.PRIMARY_EMAIL) = '')
                AND ((REGEXP_COUNT(CVA.AR_EMAIL, '@') = 1) OR CVA.AR_EMAIL IS NULL OR TRIM(CVA.AR_EMAIL) = '')
                AND ((REGEXP_COUNT(CVA.ACH_EMAIL, '@') = 1) OR CVA.ACH_EMAIL IS NULL OR TRIM(CVA.ACH_EMAIL) = '')
                AND ((REGEXP_COUNT(CVA.EQ_NOTIFY_EMAIL, '@') = 1) OR CVA.EQ_NOTIFY_EMAIL IS NULL OR TRIM(CVA.EQ_NOTIFY_EMAIL) = '') THEN '-'
           ELSE 'One or more email addresses has 0 or more than 1 @ symbol' END AS EMAIL_ADD_COUNT,

       CASE
           WHEN CHARINDEX(CHAR(32), CVA.EQ_NOTIFY_EMAIL, 1) + CHARINDEX(CHAR(32), CVA.PRIMARY_EMAIL, 1) +
                CHARINDEX(CHAR(32), CVA.ACH_EMAIL, 1) + CHARINDEX(CHAR(32), CVA.AR_EMAIL, 1) > 0
               THEN 'Email Address with Space'
           ELSE '-' END                                                         AS EMAIL_SPACE,
       CASE
           WHEN CVA.ORG_TYPE = 'Other (Please explain)' THEN 'Org Type is set to Other. Need valid org type'
           ELSE '-' END                                                         AS ORG_TYPE_CHECK,
       CASE
           WHEN TAX_ID.TAXID = CVA.TAX_ID THEN 'Tax ID already exists in Sage'
           ELSE '-' END                                                         AS TAX_ID_CHECK,
       CVA.*
FROM ANALYTICS.CLUSTDOC.VENDOR_APPLICATIONS_NEW CVA
         LEFT JOIN ANALYTICS.INTACCT.VENDOR INTVEND ON CVA.VENDOR_PORTAL_ID = INTVEND.VENDOR_PORTAL_ID
         LEFT JOIN ANALYTICS.INTACCT.VENDOR TAX_ID ON CVA.TAX_ID = TAX_ID.TAXID
         LEFT JOIN ANALYTICS.CLUSTDOC.CD_SYNC_LOG CSL ON CVA.VENDOR_PORTAL_ID = CSL.VENDOR_PORTAL_ID
WHERE INTVEND.VENDOR_PORTAL_ID IS NULL
  AND CSL.VENDOR_PORTAL_ID IS NULL
      ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: application_number {
    type: number
    sql: ${TABLE}."APPLICATION_NUMBER" ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: legal {
    type: string
    sql: ${TABLE}."LEGAL" ;;
  }

  dimension: rout_num_check {
    type: string
    sql: ${TABLE}."ROUT_NUM_CHECK" ;;
  }

  dimension: bank_acct_num_check {
    type: string
    sql: ${TABLE}."BANK_ACCT_NUM_CHECK" ;;
  }

  dimension: TAX_ID_CHECK {
    type: string
    sql: ${TABLE}."TAX_ID_CHECK" ;;
  }


  dimension: tax_id_length {
    type: string
    sql: ${TABLE}."TAX_ID_LENGTH" ;;
  }

  dimension: tax_id_trim {
    type: string
    sql: ${TABLE}."TAX_ID_TRIM" ;;
  }

  dimension: tax_id_hyphen {
    type: string
    sql: ${TABLE}."TAX_ID_HYPHEN" ;;
  }

  dimension: routing_length {
    type: string
    sql: ${TABLE}."ROUTING_LENGTH" ;;
  }

  dimension: phone_length {
    type: string
    sql: ${TABLE}."PHONE_LENGTH" ;;
  }

  dimension: email_add_count {
    type: string
    sql: ${TABLE}."EMAIL_ADD_COUNT" ;;
  }

  dimension: email_space {
    type: string
    sql: ${TABLE}."EMAIL_SPACE" ;;
  }

  dimension: org_type_check {
    type: string
    sql: ${TABLE}."ORG_TYPE_CHECK" ;;
  }

  dimension: vendor_portal_id {
    type: number
    sql: ${TABLE}."VENDOR_PORTAL_ID" ;;
  }

  dimension: firstname {
    type: string
    sql: ${TABLE}."FIRSTNAME" ;;
  }

  dimension: lastname {
    type: string
    sql: ${TABLE}."LASTNAME" ;;
  }

  dimension: full_name {
    type: string
    sql: ${TABLE}."FULL_NAME" ;;
  }

  dimension: initials {
    type: string
    sql: ${TABLE}."INITIALS" ;;
  }

  dimension: company {
    type: string
    sql: ${TABLE}."COMPANY" ;;
  }

  dimension: phone {
    type: string
    sql: ${TABLE}."PHONE" ;;
  }

  dimension: mention_name {
    type: string
    sql: ${TABLE}."MENTION_NAME" ;;
  }

  dimension: legal_name {
    type: string
    sql: ${TABLE}."LEGAL_NAME" ;;
  }

  dimension: dba {
    type: string
    sql: ${TABLE}."DBA" ;;
  }

  dimension: country {
    type: string
    sql: ${TABLE}."COUNTRY" ;;
  }

  dimension: addr_line_1 {
    type: string
    sql: ${TABLE}."ADDR_LINE_1" ;;
  }

  dimension: addr_line_2 {
    type: string
    sql: ${TABLE}."ADDR_LINE_2" ;;
  }

  dimension: city {
    type: string
    sql: ${TABLE}."CITY" ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}."STATE" ;;
  }

  dimension: state_prov {
    type: string
    sql: ${TABLE}."STATE_PROV" ;;
  }

  dimension: zip_code {
    type: string
    sql: ${TABLE}."ZIP_CODE" ;;
  }

  dimension: website {
    type: string
    sql: ${TABLE}."WEBSITE" ;;
  }

  dimension: org_type {
    type: string
    sql: ${TABLE}."ORG_TYPE" ;;
  }

  dimension: other_org_note {
    type: string
    sql: ${TABLE}."OTHER_ORG_NOTE" ;;
  }

  dimension: tax_id {
    type: string
    sql: ${TABLE}."TAX_ID" ;;
  }

  dimension: international_tax_id {
    type: string
    sql: ${TABLE}."INTERNATIONAL_TAX_ID" ;;
  }

  dimension: vendor_category1 {
    type: string
    sql: ${TABLE}."VENDOR_CATEGORY1" ;;
  }

  dimension: vendor_category2 {
    type: string
    sql: ${TABLE}."VENDOR_CATEGORY2" ;;
  }

  dimension: vendor_category3 {
    type: string
    sql: ${TABLE}."VENDOR_CATEGORY3" ;;
  }

  dimension: enterprise_spcl_status {
    type: string
    sql: ${TABLE}."ENTERPRISE_SPCL_STATUS" ;;
  }

  dimension: primary_diverse_classifcn {
    type: string
    sql: ${TABLE}."PRIMARY_DIVERSE_CLASSIFCN" ;;
  }

  dimension: primary_first_name {
    type: string
    sql: ${TABLE}."PRIMARY_FIRST_NAME" ;;
  }

  dimension: primary_last_name {
    type: string
    sql: ${TABLE}."PRIMARY_LAST_NAME" ;;
  }

  dimension: primary_phone {
    type: string
    sql: ${TABLE}."PRIMARY_PHONE" ;;
  }

  dimension: primary_mobile {
    type: string
    sql: ${TABLE}."PRIMARY_MOBILE" ;;
  }

  dimension: primary_fax {
    type: string
    sql: ${TABLE}."PRIMARY_FAX" ;;
  }

  dimension: primary_email {
    type: string
    sql: ${TABLE}."PRIMARY_EMAIL" ;;
  }

  dimension: primary_referral {
    type: string
    sql: ${TABLE}."PRIMARY_REFERRAL" ;;
  }

  dimension: ar_name {
    type: string
    sql: ${TABLE}."AR_NAME" ;;
  }

  dimension: ar_phone {
    type: string
    sql: ${TABLE}."AR_PHONE" ;;
  }

  dimension: ar_email {
    type: string
    sql: ${TABLE}."AR_EMAIL" ;;
  }

  dimension: ar_fax {
    type: string
    sql: ${TABLE}."AR_FAX" ;;
  }

  dimension: ach_or_chk {
    type: string
    sql: ${TABLE}."ACH_OR_CHK" ;;
  }

  dimension: ach_email {
    type: string
    sql: ${TABLE}."ACH_EMAIL" ;;
  }

  dimension: ach_rout_num {
    type: string
    sql: ${TABLE}."ACH_ROUT_NUM" ;;
  }

  dimension: ach_bank_acct_name {
    type: string
    sql: ${TABLE}."ACH_BANK_ACCT_NAME" ;;
  }

  dimension: bank_acct_num {
    type: string
    sql: ${TABLE}."BANK_ACCT_NUM" ;;
  }

  dimension: remit_addr_line1 {
    type: string
    sql: ${TABLE}."REMIT_ADDR_LINE1" ;;
  }

  dimension: remit_addr_line2 {
    type: string
    sql: ${TABLE}."REMIT_ADDR_LINE2" ;;
  }

  dimension: remit_city {
    type: string
    sql: ${TABLE}."REMIT_CITY" ;;
  }

  dimension: remit_state {
    type: string
    sql: ${TABLE}."REMIT_STATE" ;;
  }

  dimension: remit_zip {
    type: string
    sql: ${TABLE}."REMIT_ZIP" ;;
  }

  dimension: remit_country {
    type: string
    sql: ${TABLE}."REMIT_COUNTRY" ;;
  }

  dimension: pmt_terms {
    type: string
    sql: ${TABLE}."PMT_TERMS" ;;
  }

  dimension: invoices_from {
    type: string
    sql: ${TABLE}."INVOICES_FROM" ;;
  }

  dimension: need_te_form {
    type: string
    sql: ${TABLE}."NEED_TE_FORM" ;;
  }

  dimension: need_coi_form {
    type: string
    sql: ${TABLE}."NEED_COI_FORM" ;;
  }

  dimension: template_id {
    type: number
    sql: ${TABLE}."TEMPLATE_ID" ;;
  }

  dimension: external_id {
    type: string
    sql: ${TABLE}."EXTERNAL_ID" ;;
  }

  dimension: status_string {
    type: string
    sql: ${TABLE}."STATUS_STRING" ;;
  }

  dimension: progress_percentage {
    type: number
    sql: ${TABLE}."PROGRESS_PERCENTAGE" ;;
  }

  dimension_group: created_at {
    type: time
    sql: ${TABLE}."CREATED_AT" ;;
  }

  dimension_group: closed_at {
    type: time
    sql: ${TABLE}."CLOSED_AT" ;;
  }

  dimension: eq_notify_email {
    type: string
    sql: ${TABLE}."EQ_NOTIFY_EMAIL" ;;
  }

  set: detail {
    fields: [
      application_number,
      company_name,
      legal,
      rout_num_check,
      bank_acct_num_check,
      tax_id_length,
      tax_id_trim,
      tax_id_hyphen,
      routing_length,
      phone_length,
      email_add_count,
      email_space,
      org_type_check,
      vendor_portal_id,
      firstname,
      lastname,
      full_name,
      initials,
      company,
      phone,
      mention_name,
      legal_name,
      dba,
      country,
      addr_line_1,
      addr_line_2,
      city,
      state,
      state_prov,
      zip_code,
      website,
      org_type,
      other_org_note,
      tax_id,
      international_tax_id,
      vendor_category1,
      vendor_category2,
      vendor_category3,
      enterprise_spcl_status,
      primary_diverse_classifcn,
      primary_first_name,
      primary_last_name,
      primary_phone,
      primary_mobile,
      primary_fax,
      primary_email,
      primary_referral,
      ar_name,
      ar_phone,
      ar_email,
      ar_fax,
      ach_or_chk,
      ach_email,
      ach_rout_num,
      ach_bank_acct_name,
      bank_acct_num,
      remit_addr_line1,
      remit_addr_line2,
      remit_city,
      remit_state,
      remit_zip,
      remit_country,
      pmt_terms,
      invoices_from,
      need_te_form,
      need_coi_form,
      template_id,
      external_id,
      status_string,
      progress_percentage,
      created_at_time,
      closed_at_time,
      eq_notify_email
    ]
  }
}
