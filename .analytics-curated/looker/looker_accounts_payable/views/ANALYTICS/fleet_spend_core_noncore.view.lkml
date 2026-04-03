view: fleet_spend_core_noncore {
  sql_table_name: "ANALYTICS"."TREASURY"."FLEET_SPEND_CORE_NONCORE" ;;

  ######## DIMENSIONS ########

  dimension: _row {
    type: number
    sql: ${TABLE}."_ROW" ;;
  }

  dimension: asset_id {
    type: string
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: bo_b {
    type: string
    sql: ${TABLE}."BO_B" ;;
  }

  dimension: core_vs_non_core {
    type: string
    sql: ${TABLE}."CORE_VS_NON_CORE" ;;
  }

  dimension: factory_build_specs {
    type: string
    sql: ${TABLE}."FACTORY_BUILD_SPECS" ;;
  }

  dimension: finance_category {
    type: string
    sql: ${TABLE}."FINANCE_CATEGORY" ;;
  }

  dimension: fleet_core_mapping {
    type: string
    sql: ${TABLE}."FLEET_CORE_MAPPING" ;;
  }

  dimension_group: invoice {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."INVOICE_DATE" ;;
  }

  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }

  dimension: payment_date {
    type: string
    sql: ${TABLE}."PAYMENT_DATE" ;;
  }

  dimension_group: submit {
    type: time
    convert_tz: no
    sql: ${payment_date} ;;
  }

  dimension: total_oec {
    label: "Total OEC"
    value_format_name: usd
    type: number
    sql: ${TABLE}."TOTAL_OEC" ;;
  }

  dimension: is_current_week {
    type: yesno
    sql:
      CASE
        WHEN DATE_TRUNC('week', ${submit_date}::DATE) = DATE_TRUNC('week', CURRENT_DATE::DATE)
        THEN TRUE
        ELSE FALSE
      END ;;
  }

  dimension: is_current_week_last_year {
    type: yesno
    sql:
      CASE
        WHEN DATE_TRUNC('week', ${submit_date}::DATE) = DATE_TRUNC('week', CURRENT_DATE::DATE - INTERVAL '1 year')
        THEN TRUE
        ELSE FALSE
      END ;;
  }

  dimension: last_year_ytd_flag {
    type: yesno
    sql:
    CASE
      WHEN ${submit_date}::DATE BETWEEN DATE_TRUNC('year', CURRENT_DATE::DATE - INTERVAL '1 year')
        AND DATE_TRUNC('day', CURRENT_DATE::DATE - INTERVAL '1 year')
      THEN TRUE
      ELSE FALSE
    END ;;
  }

  ######## MEASURES ########

  measure: ytd {
    label: "2026 YTD"
    value_format_name: usd_0
    type: sum
    sql: ${TABLE}."TOTAL_OEC" ;;
    drill_fields: [trx_details*]
    filters: [submit_date: "this year",
      is_current_week: "no",
      is_current_week_last_year: "no"]
  }

  measure: run_rate_2026 {
    label: "2026 Run Rate"
    value_format_name: usd_0
    type: sum
    sql: (${TABLE}."TOTAL_OEC"/(datediff(day,'2026-01-01',current_date)))*365 ;;
    filters: [submit_date: "this year",
      is_current_week: "no",
      is_current_week_last_year: "no"]
  }

  measure: prior_ytd {
    label: "2025 YTD"
    value_format_name: usd_0
    type: sum
    sql: ${TABLE}."TOTAL_OEC" ;;
    drill_fields: [trx_details*]
    filters: [last_year_ytd_flag: "yes",
      is_current_week: "no",
      is_current_week_last_year: "no"]
  }

  measure: prior_year {
    label: "2025 Spend"
    value_format_name: usd_0
    type: sum
    sql: ${TABLE}."TOTAL_OEC" ;;
    drill_fields: [trx_details*]
    filters: [submit_date: "last year",
      is_current_week: "no",
      is_current_week_last_year: "no"]
  }

  ######## DRILL FIELDS ########

  set: trx_details {
    fields: [
      _row, asset_id, bo_b, fleet_core_mapping, finance_category, invoice_number, payment_date, invoice_date, make, model, factory_build_specs, total_oec
    ]
  }

}
