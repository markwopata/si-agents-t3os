view: credit_app_master_list {
  sql_table_name: "GS"."CREDIT_APP_MASTER_LIST"
    ;;

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

  dimension: _row {
    type: number
    sql: ${TABLE}."_ROW" ;;
  }

  dimension: app_status {
    type: string
    sql: ${TABLE}."APP_STATUS" ;;
  }

  dimension: credit_specialist {
    type: string
    sql: ${TABLE}."CREDIT_SPECIALIST" ;;
  }

  dimension: customer_name {
    type: string
    sql: ${TABLE}."CUSTOMER" ;;
  }

  dimension: customer_id {
    primary_key: yes
    type: string
    sql: ${TABLE}."CUSTOMER_ID" ;;
  }

  dimension_group: date_completed {
    # type: date
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
    sql: ${TABLE}."DATE_COMPLETED";;
  }

  dimension: date_received {
    type: string
    sql: ${TABLE}."DATE_RECEIVED" ;;
  }

  dimension: duns_ {
    type: string
    sql: ${TABLE}."DUNS_" ;;
  }

  dimension: es_admin_setup {
    type: string
    sql: ${TABLE}."ES_ADMIN_SETUP" ;;
  }

  dimension: market {
    type: string
    sql: ${TABLE}."MARKET" ;;
  }

  dimension: market_id {
    type: number
    # sql: ${TABLE}."MARKET_ID" ;;
    sql: CASE WHEN replace( ${market_id_string},',','') = '' THEN NULL ELSE replace( ${market_id_string},',','')::INT END;;
  }

  dimension: market_id_string {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: naics_1 {
    type: string
    sql: ${TABLE}."NAICS_1" ;;
  }

  dimension: naics_2 {
    type: string
    sql: ${TABLE}."NAICS_2" ;;
  }

  dimension: notes {
    type: string
    sql: ${TABLE}."NOTES" ;;
  }

  dimension: ofac {
    type: string
    sql: ${TABLE}."OFAC" ;;
  }

  dimension: sales_person {
    type: string
    sql: ${TABLE}."SALES_PERSON" ;;
  }

  dimension: salesperson_user_id {
    type: number
    sql: CASE WHEN ${TABLE}."SALESPERSON_USER_ID" IS NULL THEN 0 ELSE ${TABLE}."SALESPERSON_USER_ID" END;;
  }

  dimension: sic {
    type: string
    sql: ${TABLE}."SIC" ;;
  }

  dimension: tin {
    type: string
    sql: ${TABLE}."TIN" ;;
  }

  dimension: xero_setup {
    type: string
    sql: ${TABLE}."XERO_SETUP" ;;
  }

  dimension: test {
    type: date
    sql: date_trunc(month,current_date()) ;;
  }

  dimension: test_2 {
    type: date
    sql: date_trunc(month,${date_completed_raw}::DATE) ;;
  }

 dimension: app_is_current_month {
  type: yesno
  sql: DATE_TRUNC('month',current_timestamp::DATE)::DATE =  replace(date_trunc('month',${date_completed_raw}::date),'00','20')::DATE;;
}

dimension: app_is_previous_month {
  type: yesno
  sql: (DATE_TRUNC('month',current_timestamp::DATE)::DATE - interval '1 month')::DATE = replace(DATE_TRUNC('month', ${date_completed_raw}::DATE),'00','20')::DATE;;
}

  measure: apps_current_month {
    type: count
    filters: [app_is_current_month: "Yes" ]
    drill_fields: [sales_person ,customer_name,customer_id,market, date_completed_raw]
  }

  measure: apps_previous_month {
    type: count
    filters: [app_is_previous_month: "Yes" ]
    drill_fields: [sales_person ,customer_name,customer_id,market, date_completed_raw]
  }

  measure: count {
    type: count
    drill_fields: [sales_person ,customer_name,customer_id,market, date_completed_raw]
  }


}
