view: glaccount {
  sql_table_name: "ANALYTICS"."INTACCT"."GLACCOUNT" ;;

  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension: accountno {
    type: string
    sql: ${TABLE}."ACCOUNTNO" ;;
  }

  #### created by KA specifically for use in eCommerce Profit and Loss explore
  dimension: account_is_payroll_or_benefits_related {
    type: yesno
    sql: try_to_number(${accountno}) in (7500, 7501, 7506, 7507, 7700, 7703, 7705) ;;
  }
  dimension: account_is_fulfillment_center_specific {
    type: yesno
    sql: try_to_number(${accountno}) in (6014, 6306, 6307, 7600, 7603, 7604, 7608, 7624, 7801, 7802) ;;
  }
  dimension: account_type {
    type: string
    sql: iff(${TABLE}."CATEGORY" ilike '%cost%' or ${TABLE}."CATEGORY" ilike '%expense%', 'EXPENSE', 'REVENUE') ;;
  }

  #### end created by KA specifically for use in eCommerce Profit and Loss explore section

  dimension: account_is_misc_spend {
    type: yesno
    description: "Misc Spend Accounts for the Supplier Performance and Vendor Scorecard Dashboards. List managed by Kaelen Jones"
    sql:
      iff(
        ${accountno} not in (1301, 1307, 1316, 6026, 2303, 2390) -- Restarting Misc spend designations in 11/2025 --TA
          --6306
          --, 7614
          --, 7403
          --, 7400
          --, 1501
          --, 1505
          --, 1610
          --, 5021
          --, 6007
          --, 6302
          --, 6307
          --, 6327
          --, 6305
          --, 6320
          --, 6016
          --, 7304
          --, 6014
          --, 1504
          --, 6032
          --, 1310
          --, 6300)
          , true
          , false);;
  }

  dimension: is_supplier_performance_account {
    type: yesno
    description: "Spend Accounts for the Supplier Performance and Vendor Scorecard Dashboards. List managed by Kaelen Jones"
    sql:
      iff(
        ${accountno} not in (1307, 1316, 6026, 2303, 2390) -- Restarting Misc spend designations in 11/2025 --TA
          --6306
          --, 7614
          --, 7403
          --, 7400
          --, 1501
          --, 1505
          --, 1610
          --, 5021
          --, 6007
          --, 6302
          --, 6307
          --, 6327
          --, 6305
          --, 6320
          --, 6016
          --, 7304
          --, 6014
          --, 1504
          --, 6032
          --, 1310
          --, 6300
          --, 1301)
          , true
          , false);;
  }

  dimension: accounttype {
    type: string
    sql: ${TABLE}."ACCOUNTTYPE" ;;
  }
  dimension: alternativeaccount {
    type: string
    sql: ${TABLE}."ALTERNATIVEACCOUNT" ;;
  }
  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }
  dimension: categorykey {
    type: string
    sql: ${TABLE}."CATEGORYKEY" ;;
  }
  dimension: closetoacctkey {
    type: number
    sql: ${TABLE}."CLOSETOACCTKEY" ;;
  }
  dimension: closingtype {
    type: string
    sql: ${TABLE}."CLOSINGTYPE" ;;
  }
  dimension: createdby {
    type: number
    sql: ${TABLE}."CREATEDBY" ;;
  }
  dimension_group: ddsreadtime {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DDSREADTIME" AS TIMESTAMP_NTZ) ;;
  }
  dimension: gj_restricted {
    type: yesno
    sql: ${TABLE}."GJ_RESTRICTED" ;;
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
  dimension: modifiedby {
    type: number
    sql: ${TABLE}."MODIFIEDBY" ;;
  }
  dimension: mrccode {
    type: string
    sql: ${TABLE}."MRCCODE" ;;
  }
  dimension: normalbalance {
    type: string
    sql: ${TABLE}."NORMALBALANCE" ;;
  }
  dimension: recordno {
    type: number
    primary_key: yes
    sql: ${TABLE}."RECORDNO" ;;
  }
  dimension: requireclass {
    type: yesno
    sql: ${TABLE}."REQUIRECLASS" ;;
  }
  dimension: requirecustomer {
    type: yesno
    sql: ${TABLE}."REQUIRECUSTOMER" ;;
  }
  dimension: requiredept {
    type: yesno
    sql: ${TABLE}."REQUIREDEPT" ;;
  }
  dimension: requireemployee {
    type: yesno
    sql: ${TABLE}."REQUIREEMPLOYEE" ;;
  }
  dimension: requiregldimasset {
    type: yesno
    sql: ${TABLE}."REQUIREGLDIMASSET" ;;
  }
  dimension: requiregldimtransaction_identifier {
    type: yesno
    sql: ${TABLE}."REQUIREGLDIMTRANSACTION_IDENTIFIER" ;;
  }
  dimension: requiregldimud_loan {
    type: yesno
    sql: ${TABLE}."REQUIREGLDIMUD_LOAN" ;;
  }
  dimension: requireitem {
    type: yesno
    sql: ${TABLE}."REQUIREITEM" ;;
  }
  dimension: requireloc {
    type: yesno
    sql: ${TABLE}."REQUIRELOC" ;;
  }
  dimension: requirevendor {
    type: yesno
    sql: ${TABLE}."REQUIREVENDOR" ;;
  }
  dimension: sl_restricted {
    type: yesno
    sql: ${TABLE}."SL_RESTRICTED" ;;
  }
  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }
  dimension: subledgercontrolon {
    type: yesno
    sql: ${TABLE}."SUBLEDGERCONTROLON" ;;
  }
  dimension: taxable {
    type: yesno
    sql: ${TABLE}."TAXABLE" ;;
  }
  dimension: taxcode {
    type: string
    sql: ${TABLE}."TAXCODE" ;;
  }
  dimension: title {
    type: string
    sql: ${TABLE}."TITLE" ;;
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
  measure: count {
    type: count
    drill_fields: [megaentityname]
  }
}
