view: overdue_inspection_totals {
  # There are 2 records per branch each day
  # sql_table_name: "ANALYTICS"."SERVICE"."OVERDUE_INSPECTION_TOTALS"
  derived_table: {
    sql:
SELECT date_recorded,
       asset_service_branch_id,
       overdue_ansi,
       overdue_dot,
       overdue_pm,
       overdue_annual
  FROM analytics.service.overdue_inspection_totals
  QUALIFY ROW_NUMBER() OVER (PARTITION BY asset_service_branch_id ORDER BY date_recorded DESC) = 1
    ;;
  }


  dimension: pkey {
    primary_key: yes
    type: number
    sql: ${TABLE}."PKEY" ;;
  }

  dimension_group: date_recorded {
    type: time
    timeframes: [
      date,
      week,
      month,
      year
    ]
    sql: ${TABLE}."DATE_RECORDED" ;;
  }

  dimension: asset_service_branch_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."ASSET_SERVICE_BRANCH_ID" ;;
  }

  dimension: overdue_ansi {
    type: number
    sql: ${TABLE}."OVERDUE_ANSI" ;;
  }

  dimension: overdue_dot {
    type: number
    sql: ${TABLE}."OVERDUE_DOT" ;;
  }

  dimension: overdue_pm {
    type: number
    sql: ${TABLE}."OVERDUE_PM" ;;
  }

  dimension: overdue_annual {
    type: number
    sql: ${TABLE}."OVERDUE_ANNUAL" ;;
  }

  # - - - - - MEASURES - - - - -

  measure: total_overdue_ansi {
    label: "Total Overdue ANSI"
    type: sum
    sql: IFF(${date_recorded_date} = CURRENT_DATE(), ${overdue_ansi}, null) ;;
    drill_fields: [asset_service_branch_id, total_overdue_ansi]
  }

  measure: total_overdue_dot {
    label: "Total Overdue DOT"
    type: sum
    sql: IFF(${date_recorded_date} = CURRENT_DATE(), ${overdue_dot}, null) ;;
    drill_fields: [asset_service_branch_id, total_overdue_dot]
  }

  measure: total_overdue_pm {
    label: "Total Overdue PM"
    type: sum
    sql: IFF(${date_recorded_date} = CURRENT_DATE(), ${overdue_pm}, null) ;;
    drill_fields: [asset_service_branch_id, total_overdue_pm]
  }

  measure: total_overdue_annual {
    label: "Total Overdue Annual"
    type: sum
    sql: IFF(${date_recorded_date} = CURRENT_DATE(), ${overdue_annual}, null) ;;
    drill_fields: [asset_service_branch_id, total_overdue_annual]
  }
}
