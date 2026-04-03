view: vendor {
  sql_table_name: "ANALYTICS"."INTACCT"."VENDOR" ;;
  drill_fields: [vendorid]

  dimension: vendorid {
    primary_key: yes
    type: string
    sql: ${TABLE}."VENDORID" ;;
  }
  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension: accountkey {
    type: number
    sql: ${TABLE}."ACCOUNTKEY" ;;
  }
  dimension: accountlabelkey {
    type: number
    sql: ${TABLE}."ACCOUNTLABELKEY" ;;
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
  dimension: alt_pay_due_date_deduction {
    type: number
    sql: ${TABLE}."ALT_PAY_DUE_DATE_DEDUCTION" ;;
  }
  dimension: alt_pay_method {
    type: string
    sql: ${TABLE}."ALT_PAY_METHOD" ;;
  }
  dimension: amex_bank_account_address_id {
    type: string
    sql: ${TABLE}."AMEX_BANK_ACCOUNT_ADDRESS_ID" ;;
  }
  dimension: amex_bank_account_id {
    type: string
    sql: ${TABLE}."AMEX_BANK_ACCOUNT_ID" ;;
  }
  dimension: billingtype {
    type: string
    sql: ${TABLE}."BILLINGTYPE" ;;
  }
  dimension: cardstate {
    type: string
    sql: ${TABLE}."CARDSTATE" ;;
  }
  dimension: checkenabled {
    type: yesno
    sql: ${TABLE}."CHECKENABLED" ;;
  }
  dimension: coi_url {
    type: string
    sql: ${TABLE}."COI_URL" ;;
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
  dimension: contactkey1099 {
    type: number
    sql: ${TABLE}."CONTACTKEY1099" ;;
  }
  dimension: createdby {
    type: number
    sql: ${TABLE}."CREATEDBY" ;;
  }
  dimension: creditlimit {
    type: number
    sql: ${TABLE}."CREDITLIMIT" ;;
  }
  dimension: currency {
    type: string
    sql: ${TABLE}."CURRENCY" ;;
  }
  dimension_group: ddsreadtime {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DDSREADTIME" AS TIMESTAMP_NTZ) ;;
  }
  dimension: default_lead_time {
    type: number
    sql: ${TABLE}."DEFAULT_LEAD_TIME" ;;
  }
  dimension: discount {
    type: number
    sql: ${TABLE}."DISCOUNT" ;;
  }
  dimension: displaycontact_mailaddress_latitude {
    type: number
    sql: ${TABLE}."DISPLAYCONTACT_MAILADDRESS_LATITUDE" ;;
  }
  dimension: displaycontact_mailaddress_longitude {
    type: number
    sql: ${TABLE}."DISPLAYCONTACT_MAILADDRESS_LONGITUDE" ;;
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
  dimension: diversity_classification {
    type: string
    sql: ${TABLE}."DIVERSITY_CLASSIFICATION" ;;
  }
  dimension: donotcutcheck {
    type: yesno
    sql: ${TABLE}."DONOTCUTCHECK" ;;
  }
  dimension_group: earliest_coi_expiration {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."EARLIEST_COI_EXPIRATION_DATE" ;;
  }
  dimension: entity {
    type: string
    sql: ${TABLE}."ENTITY" ;;
  }
  dimension: epay_interest {
    type: string
    sql: ${TABLE}."EPAY_INTEREST" ;;
  }
  dimension: esadmin_ref {
    type: string
    sql: ${TABLE}."ESADMIN_REF" ;;
  }
  dimension: excl_from_ext {
    type: yesno
    sql: ${TABLE}."EXCL_FROM_EXT" ;;
  }
  dimension: external_sync_override {
    type: string
    sql: ${TABLE}."EXTERNAL_SYNC_OVERRIDE" ;;
  }
  dimension: filepaymentservice {
    type: string
    sql: ${TABLE}."FILEPAYMENTSERVICE" ;;
  }
  dimension: form1099_box {
    type: string
    sql: ${TABLE}."FORM1099BOX" ;;
  }
  dimension: form1099_type {
    type: string
    sql: ${TABLE}."FORM1099TYPE" ;;
  }
  dimension: glgrpkey {
    type: number
    sql: ${TABLE}."GLGRPKEY" ;;
  }
  dimension: isindividual {
    type: yesno
    sql: ${TABLE}."ISINDIVIDUAL" ;;
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
    label: "Vendor"
    type: string
    sql: ${TABLE}."NAME" ;;
  }
  dimension: name1099 {
    type: string
    sql: ${TABLE}."NAME1099" ;;
  }
  dimension: objectrestriction {
    type: string
    sql: ${TABLE}."OBJECTRESTRICTION" ;;
  }
  dimension: oeprclstkey {
    type: number
    sql: ${TABLE}."OEPRCLSTKEY" ;;
  }
  dimension: onetime {
    type: yesno
    sql: ${TABLE}."ONETIME" ;;
  }
  dimension: onhold {
    type: yesno
    sql: ${TABLE}."ONHOLD" ;;
  }
  dimension: outsourceach {
    type: yesno
    sql: ${TABLE}."OUTSOURCEACH" ;;
  }
  dimension: outsourceachstate {
    type: string
    sql: ${TABLE}."OUTSOURCEACHSTATE" ;;
  }
  dimension: outsourcecard {
    type: yesno
    sql: ${TABLE}."OUTSOURCECARD" ;;
  }
  dimension: outsourcecardoverride {
    type: yesno
    sql: ${TABLE}."OUTSOURCECARDOVERRIDE" ;;
  }
  dimension: outsourcecheck {
    type: yesno
    sql: ${TABLE}."OUTSOURCECHECK" ;;
  }
  dimension: outsourcecheckstate {
    type: string
    sql: ${TABLE}."OUTSOURCECHECKSTATE" ;;
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
  dimension: paymethodrec {
    type: number
    sql: ${TABLE}."PAYMETHODREC" ;;
  }
  dimension: paytokey {
    type: number
    sql: ${TABLE}."PAYTOKEY" ;;
  }
  dimension: pmplusemail {
    type: string
    sql: ${TABLE}."PMPLUSEMAIL" ;;
  }
  dimension: pmplusfax {
    type: string
    sql: ${TABLE}."PMPLUSFAX" ;;
  }
  dimension: pmplusremittancetype {
    type: string
    sql: ${TABLE}."PMPLUSREMITTANCETYPE" ;;
  }
  dimension: priceschedule {
    type: string
    sql: ${TABLE}."PRICESCHEDULE" ;;
  }
  dimension: primarycontactkey {
    type: number
    sql: ${TABLE}."PRIMARYCONTACTKEY" ;;
  }
  dimension: pymtcountrycode {
    type: string
    sql: ${TABLE}."PYMTCOUNTRYCODE" ;;
  }
  dimension: recordno {
    type: number
    sql: ${TABLE}."RECORDNO" ;;
  }
  dimension: reporting_category {
    type: string
    sql: ${TABLE}."REPORTING_CATEGORY" ;;
  }
  dimension: requires_coi {
    type: yesno
    sql: ${TABLE}."REQUIRES_COI" ;;
  }
  dimension: retainagepercentage {
    type: number
    sql: ${TABLE}."RETAINAGEPERCENTAGE" ;;
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
  dimension: totaldue {
    type: number
    sql: ${TABLE}."TOTALDUE" ;;
  }
  dimension: ud_foreign_tin {
    type: string
    sql: ${TABLE}."UD_FOREIGN_TIN" ;;
  }
  dimension: ud_vendor_esemailnotify {
    type: string
    sql: ${TABLE}."UD_VENDOR_ESEMAILNOTIFY" ;;
  }
  dimension: ud_vendor_invoicing_email_address {
    type: string
    sql: ${TABLE}."UD_VENDOR_INVOICING_EMAIL_ADDRESS" ;;
  }
  dimension: ud_vendor_purchases_financed_by {
    type: string
    sql: ${TABLE}."UD_VENDOR_PURCHASES_FINANCED_BY" ;;
  }
  dimension: vendor_amex_card_affiliate_id {
    type: string
    sql: ${TABLE}."VENDOR_AMEX_CARD_AFFILIATE_ID" ;;
  }
  dimension: vendor_amex_cd_affiliate_id {
    type: string
    sql: ${TABLE}."VENDOR_AMEX_CD_AFFILIATE_ID" ;;
  }
  dimension: vendor_amex_org_address_id {
    type: string
    sql: ${TABLE}."VENDOR_AMEX_ORG_ADDRESS_ID" ;;
  }
  dimension: vendor_amex_organization_id {
    type: string
    sql: ${TABLE}."VENDOR_AMEX_ORGANIZATION_ID" ;;
  }
  dimension: vendor_category {
    type: string
    sql: ${TABLE}."VENDOR_CATEGORY" ;;
  }
  dimension: vendor_portal_id {
    type: number
    sql: ${TABLE}."VENDOR_PORTAL_ID" ;;
  }
  dimension: vendor_redirect {
    type: string
    sql: ${TABLE}."VENDOR_REDIRECT" ;;
  }
  dimension: vendoraccountoutsourceach {
    type: string
    sql: ${TABLE}."VENDORACCOUNTOUTSOURCEACH" ;;
  }
  dimension: vendoracctnokey {
    type: number
    sql: ${TABLE}."VENDORACCTNOKEY" ;;
  }
  dimension: vendorachaccountid {
    type: string
    sql: ${TABLE}."VENDORACHACCOUNTID" ;;
  }
  dimension: vendtype {
    type: string
    sql: ${TABLE}."VENDTYPE" ;;
  }
  dimension: vendtypekey {
    type: number
    sql: ${TABLE}."VENDTYPEKEY" ;;
  }
  dimension_group: whencreated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."WHENCREATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: whenmodified {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."WHENMODIFIED" AS TIMESTAMP_NTZ) ;;
  }
  dimension: wireaccounttype {
    type: string
    sql: ${TABLE}."WIREACCOUNTTYPE" ;;
  }
  dimension: wirebankname {
    type: string
    sql: ${TABLE}."WIREBANKNAME" ;;
  }
  dimension: wirebankroutingnumber {
    type: string
    sql: ${TABLE}."WIREBANKROUTINGNUMBER" ;;
  }
  dimension: wireenabled {
    type: yesno
    sql: ${TABLE}."WIREENABLED" ;;
  }
  measure: count {
    type: count
    drill_fields: [detail*]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
  vendorid,
  name,
  termname,
  megaentityname,
  company_legal_name,
  wirebankname
  ]
  }

}

view: vendor_payment_term_score {
  derived_table: {
    sql:
with cte as (
    select v.vendorid
        , tvm.mapped_vendor_name
        , tvm.vendor_type
        , termname
        , case
            when termname ilike '%due%upon%receipt%' then 0
            when termname ilike '%of%month%' then 30
            when termname ilike '%net%' then round(right(termname, 2), 0)
            else null end as term
    from ANALYTICS.INTACCT.VENDOR v
    join ANALYTICS.PARTS_INVENTORY.TOP_VENDOR_MAPPING tvm
        on tvm.vendorid = v.vendorid
            and primary_vendor ilike 'yes'
)

select a.vendorid
    , a.termname
    , a.term
    , avg(pa.term) as peer_avg_term
    , greatest(coalesce(peer_avg_term, 0), 90) as graded_target
    , iff((a.term / graded_target) * (1/14) > (1/14), (1/14), (a.term / graded_target) * (1/14)) as vendor_term_score
    , iff((a.term / graded_target) * (10) > (10), (10), (a.term / graded_target) * (10)) as vendor_term_score10
from cte a
left join cte pa
    on pa.mapped_vendor_name <> a.mapped_vendor_name
        and pa.vendor_type = a.vendor_type
group by 1,2,3;;
  }
  dimension: vendorid {
    type: string
    sql: ${TABLE}.vendorid ;;
  }
  dimension: termname {
    type: string
    sql: ${TABLE}.termname ;;
  }
  dimension: vendor_term {
    type: number
    sql: ${TABLE}.term ;;
  }
  dimension: peer_avg_term {
    type: number
    value_format_name: decimal_1
    sql: ${TABLE}.peer_avg_term ;;
  }
  dimension: graded_target {
    type: number
    value_format_name: decimal_1
    sql: ${TABLE}.graded_target ;;
  }
  dimension: vendor_term_score {
    type: number
    value_format_name: decimal_2
    sql: coalesce(${TABLE}.vendor_term_score, 0) ;;
  }
  dimension: vendor_term_score10 {
    type: number
    value_format_name: decimal_1
    sql: coalesce(${TABLE}.vendor_term_score10, 0) ;;
  }
}
