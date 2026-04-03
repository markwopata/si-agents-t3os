view: trovata_transactions_moberly_uk {
  sql_table_name: "ANALYTICS"."TREASURY"."TROVATA_TRANSACTIONS_MOBERLY_UK" ;;

######## DIMENSIONS ########

  dimension: accountnumber {
    type: string
    sql: ${TABLE}."ACCOUNTNUMBER" ;;
  }

  dimension_group: date {
    type: time
    sql: ${TABLE}."DATE" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: tags {
    type: string
    sql: ${TABLE}."TAGS" ;;
  }

  dimension: mapping_lv_1 {
    type: string
    sql: ${TABLE}."MAPPING_LV_1" ;;
  }

  dimension: mapping_lv_2 {
    type: string
    sql: ${TABLE}."MAPPING_LV_2" ;;
  }

  dimension: is_current_week {
    type: yesno
    sql:
      CASE
        WHEN DATE_TRUNC('week', ${date_date}::DATE) = DATE_TRUNC('week', CURRENT_DATE)
        THEN TRUE
        ELSE FALSE
      END ;;
  }


  dimension: is_current_week_last_year {
    type: yesno
    sql:
      CASE
        WHEN DATE_TRUNC('week', ${date_date}::DATE) = DATE_TRUNC('week', CURRENT_DATE - INTERVAL '1 year')
        THEN TRUE
        ELSE FALSE
      END ;;
  }

  dimension: last_year_ytd_flag {
    type: yesno
    sql:
    CASE
      WHEN ${date_date}::DATE BETWEEN DATE_TRUNC('year', CURRENT_DATE::DATE - INTERVAL '1 year')
        AND DATE_TRUNC('day', CURRENT_DATE::DATE - INTERVAL '1 year')
      THEN TRUE
      ELSE FALSE
    END ;;
  }


  ######## MEASURES ########

  measure: amount {
    value_format_name: usd
    type: sum
    sql: ${TABLE}."AMOUNT" ;;
  }

  measure: ytd {
    label: "2026 YTD"
    value_format_name: usd_0
    type: sum
    sql: ${TABLE}."AMOUNT" ;;
    drill_fields: [trx_details*]
    filters: [date_year: "this year",
      is_current_week: "no"]
  }

  measure: prior_ytd {
    label: "2025 YTD"
    value_format_name: usd_0
    type: sum
    sql: ${TABLE}."AMOUNT" ;;
    drill_fields: [trx_details*]
    filters: [last_year_ytd_flag: "yes",
      is_current_week: "no",
      is_current_week_last_year: "no"]
  }

  measure: qtd {
    label: "QTD"
    value_format_name: usd_0
    type: sum
    sql: ${TABLE}."AMOUNT" ;;
    drill_fields: [trx_details*]
    filters: [date_quarter: "this quarter",
      is_current_week: "no"]
  }

  measure: mtd {
    label: "MTD"
    value_format_name: usd_0
    type: sum
    sql: ${TABLE}."AMOUNT" ;;
    drill_fields: [trx_details*]
    filters: [date_month: "this month",
      is_current_week: "no"]
  }

  measure: current_week {
    label: "Current Wk"
    value_format_name: usd_0
    type: sum
    sql: ${TABLE}."AMOUNT" ;;
    drill_fields: [trx_details*]
    filters: [date_week: "this week",
      is_current_week: "no"]
  }

  measure: prior_week {
    label: "Prior Wk"
    value_format_name: usd_0
    type: sum
    sql: ${TABLE}."AMOUNT" ;;
    drill_fields: [trx_details*]
    filters: [date_week: "last week",
      is_current_week: "no"]
  }

  measure: prior_year {
    label: "Prior Yr Total"
    value_format_name: usd_0
    type: sum
    sql: ${TABLE}."AMOUNT" ;;
    drill_fields: [trx_details*]
    filters: [date_year: "last year",
      is_current_week: "no",
      is_current_week_last_year: "no"]
  }

  measure: run_rate_2026 {
    label: "2026 Run Rate"
    value_format_name: usd_0
    type: sum
    sql: (${TABLE}."AMOUNT"/(datediff(day,'2026-01-01',current_date)))*365 ;;
    filters: [date_year: "this year",
      is_current_week: "no"]
  }

  ############## DRILL FIELDS ##############
  set: trx_details {
    fields: [date_date,tags,amount]
  }



}
