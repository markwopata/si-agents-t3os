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

  dimension: gsa {
    type: string
    sql:  ${TABLE}."PREFS":"general_services_administration" ;;
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

  dimension: rental_billing_cycle_strategy {
    type: string
    sql: ${TABLE}."RENTAL_BILLING_CYCLE_STRATEGY" ;;
  }

  ########################## the dimensions below are specific to the GSA dashboard
  ########################## the results are being uploaded to a gov site, so the fields are necessary for the export

  dimension: contract_bpa_number {
    type: string
    sql: iff(${gsa} = 'true','47QSMS24D00C9',null) ;;
  }

  dimension: unit_measure {
    type: string
    sql: iff(${gsa} = 'true','Each',null) ;;
  }

  dimension: universal_product_code {
    sql: null ;;
  }

  dimension: sin_number {
    type: number
    value_format_name: id
    sql: iff(${gsa} = 'true','532310',null) ;;
  }

  dimension: non_federal_entity {
    sql: null ;;
  }

}
