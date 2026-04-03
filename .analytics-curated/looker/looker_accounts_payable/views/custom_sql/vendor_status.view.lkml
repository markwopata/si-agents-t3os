view: vendor {
  sql_table_name: "SAGE_INTACCT"."VENDOR"
    ;;
  drill_fields: [vendorid]

  dimension: vendorid {
    primary_key: yes
    type: string
    sql: ${TABLE}."VENDORID" ;;
  }

  dimension: _fivetran_deleted {
    type: yesno
    sql: ${TABLE}."_FIVETRAN_DELETED" ;;
  }

  dimension_group: _fivetran_synced {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."_FIVETRAN_SYNCED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: accountkey {
    type: number
    sql: ${TABLE}."ACCOUNTKEY" ;;
  }

  dimension: achaccountnumber {
    type: string
    sql: ${TABLE}."ACHACCOUNTNUMBER" ;;
  }

  dimension: achaccounttype {
    type: string
    sql: ${TABLE}."ACHACCOUNTTYPE" ;;
  }

  dimension: achbankroutingnumber {
    type: string
    sql: ${TABLE}."ACHBANKROUTINGNUMBER" ;;
  }

  dimension: achenabled {
    type: yesno
    sql: ${TABLE}."ACHENABLED" ;;
  }

  dimension: achremittancetype {
    type: string
    sql: ${TABLE}."ACHREMITTANCETYPE" ;;
  }

  dimension: apaccount {
    type: number
    sql: ${TABLE}."APACCOUNT" ;;
  }

  dimension: apaccounttitle {
    type: string
    sql: ${TABLE}."APACCOUNTTITLE" ;;
  }

  dimension: billingtype {
    type: string
    sql: ${TABLE}."BILLINGTYPE" ;;
  }

  dimension: checkenabled {
    type: yesno
    sql: ${TABLE}."CHECKENABLED" ;;
  }

  dimension: comments {
    type: string
    sql: ${TABLE}."COMMENTS" ;;
  }

  dimension: company_legal_name {
    type: string
    sql: ${TABLE}."COMPANY_LEGAL_NAME" ;;
  }

  dimension: company_name_dba {
    type: string
    sql: ${TABLE}."COMPANY_NAME_DBA" ;;
  }

  dimension: contactkey_1099 {
    type: number
    sql: ${TABLE}."CONTACTKEY_1099" ;;
  }

  dimension: createdby {
    type: number
    sql: ${TABLE}."CREATEDBY" ;;
  }

  dimension: creditlimit {
    type: number
    sql: ${TABLE}."CREDITLIMIT" ;;
  }

  dimension: displaycontactkey {
    type: number
    sql: ${TABLE}."DISPLAYCONTACTKEY" ;;
  }

  dimension: displaytermdiscount {
    type: yesno
    sql: ${TABLE}."DISPLAYTERMDISCOUNT" ;;
  }

  dimension: displocacctnocheck {
    type: yesno
    sql: ${TABLE}."DISPLOCACCTNOCHECK" ;;
  }

  dimension: donotcutcheck {
    type: yesno
    sql: ${TABLE}."DONOTCUTCHECK" ;;
  }

  dimension: entity {
    type: string
    sql: ${TABLE}."ENTITY" ;;
  }

  dimension: form_1099_box {
    type: number
    sql: ${TABLE}."FORM_1099_BOX" ;;
  }

  dimension: form_1099_type {
    type: string
    sql: ${TABLE}."FORM_1099_TYPE" ;;
  }

  dimension: isowner {
    type: yesno
    sql: ${TABLE}."ISOWNER" ;;
  }

  dimension: megaentityid {
    type: string
    sql: ${TABLE}."MEGAENTITYID" ;;
  }

  dimension: megaentitykey {
    type: number
    sql: ${TABLE}."MEGAENTITYKEY" ;;
  }

  dimension: megaentityname {
    type: string
    sql: ${TABLE}."MEGAENTITYNAME" ;;
  }

  dimension: mergepaymentreq {
    type: yesno
    sql: ${TABLE}."MERGEPAYMENTREQ" ;;
  }

  dimension: modifiedby {
    type: number
    sql: ${TABLE}."MODIFIEDBY" ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: name_1099 {
    type: string
    sql: ${TABLE}."NAME_1099" ;;
  }

  dimension: offsetglaccountno {
    type: number
    sql: ${TABLE}."OFFSETGLACCOUNTNO" ;;
  }

  dimension: offsetglaccountnotitle {
    type: string
    sql: ${TABLE}."OFFSETGLACCOUNTNOTITLE" ;;
  }

  dimension: onetime {
    type: yesno
    sql: ${TABLE}."ONETIME" ;;
  }

  dimension: onhold {
    type: yesno
    sql: ${TABLE}."ONHOLD" ;;
  }

  dimension: paydatevalue {
    type: string
    sql: ${TABLE}."PAYDATEVALUE" ;;
  }

  dimension: paymentnotify {
    type: yesno
    sql: ${TABLE}."PAYMENTNOTIFY" ;;
  }

  dimension: paymentpriority {
    type: string
    sql: ${TABLE}."PAYMENTPRIORITY" ;;
  }

  dimension: paymethodkey {
    type: string
    sql: ${TABLE}."PAYMETHODKEY" ;;
  }

  dimension: paymethodrec {
    type: number
    sql: ${TABLE}."PAYMETHODREC" ;;
  }

  dimension: paytokey {
    type: number
    sql: ${TABLE}."PAYTOKEY" ;;
  }

  dimension: primarycontactkey {
    type: number
    sql: ${TABLE}."PRIMARYCONTACTKEY" ;;
  }

  dimension: recordno {
    type: string
    sql: ${TABLE}."RECORDNO" ;;
  }

  dimension: returntokey {
    type: number
    sql: ${TABLE}."RETURNTOKEY" ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }

  dimension: supdocid {
    type: string
    sql: ${TABLE}."SUPDOCID" ;;
  }

  dimension: taxid {
    type: string
    sql: ${TABLE}."TAXID" ;;
  }

  dimension: termname {
    type: string
    sql: ${TABLE}."TERMNAME" ;;
  }

  dimension: termskey {
    type: number
    sql: ${TABLE}."TERMSKEY" ;;
  }

  dimension: termvalue {
    type: string
    sql: ${TABLE}."TERMVALUE" ;;
  }

  dimension: totaldue {
    type: number
    sql: ${TABLE}."TOTALDUE" ;;
  }

  dimension: ud_foreign_tin {
    type: string
    sql: ${TABLE}."UD_FOREIGN_TIN" ;;
  }

  dimension: ud_vendor_invoicing_email_address {
    type: string
    sql: ${TABLE}."UD_VENDOR_INVOICING_EMAIL_ADDRESS" ;;
  }

  dimension: ud_vendor_purchases_financed_by {
    type: string
    sql: ${TABLE}."UD_VENDOR_PURCHASES_FINANCED_BY" ;;
  }

  dimension: vendor_category {
    type: string
    sql: ${TABLE}."VENDOR_CATEGORY" ;;
  }

  dimension: vendoraccountno {
    type: string
    sql: ${TABLE}."VENDORACCOUNTNO" ;;
  }

  dimension: vendoracctnokey {
    type: number
    sql: ${TABLE}."VENDORACCTNOKEY" ;;
  }

  dimension: vendtype {
    type: string
    sql: ${TABLE}."VENDTYPE" ;;
  }

  dimension: vendtypekey {
    type: number
    sql: ${TABLE}."VENDTYPEKEY" ;;
  }

  dimension: whencreated {
    type: string
    sql: ${TABLE}."WHENCREATED" ;;
  }

  dimension: whenmodified {
    type: string
    sql: ${TABLE}."WHENMODIFIED" ;;
  }

  dimension: wireenabled {
    type: yesno
    sql: ${TABLE}."WIREENABLED" ;;
  }

  measure: count {
    type: count
    drill_fields: [vendorid, name, termname, megaentityname, company_legal_name]
  }
}
