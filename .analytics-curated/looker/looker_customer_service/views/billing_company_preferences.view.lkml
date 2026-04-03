view: billing_company_preferences {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."BILLING_COMPANY_PREFERENCES" ;;
  drill_fields: [billing_company_preferences_id]

  dimension: billing_company_preferences_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."BILLING_COMPANY_PREFERENCES_ID" ;;
  }
  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }
  dimension_group: date_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: date_updated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_UPDATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension: prefs {
    type: string
    sql: ${TABLE}."PREFS" ;;
  }
  dimension: national_account {
    type: string
    sql: case when ${TABLE}."PREFS":"national_account" = true then 'Yes' else 'No' end ;;
  }
  dimension: gsa {
    label: "General Services Administration (GSA)"
    type: string
    sql: case when ${TABLE}."PREFS":"general_services_administration" = true then 'Yes' else 'No' end ;;
  }
  dimension: legal_audit {
    type: string
    sql: case when ${TABLE}."PREFS":"legal_audit" = true then 'Yes' else 'No' end ;;
  }
  dimension: rental_billing_cycle_strategy {
    type: string
    sql: ${TABLE}."RENTAL_BILLING_CYCLE_STRATEGY" ;;
  }
  measure: count {
    type: count
    drill_fields: [billing_company_preferences_id]
  }
}
