view: ar_weekly_dso {
  sql_table_name: "PUBLIC"."AR_WEEKLY_DSO"
    ;;

  dimension: avg_dso {
    type: number
    sql: ${TABLE}."AVG_DSO" ;;
  }

  # dimension: date_week {
  #   type: string
  dimension_group: date_week {
    type: time
      timeframes: [
        raw,
        date,
        week,
        month,
        quarter,
        year
      ]
    sql: ${TABLE}."DATE_WEEK"::DATE ;;
  }

  dimension: market_dso {
    type: number
    sql: ${TABLE}."MARKET_DSO" ;;
  }

  dimension: market_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: revenue {
    type: number
    sql: ${TABLE}."REVENUE" ;;
  }

  dimension: tot_outstanding {
    type: number
    sql: ${TABLE}."TOT_OUTSTANDING" ;;
  }

  measure: company_dso {
    type: max
    sql: ${avg_dso} ;;
  }

  measure: tot_outstanding_measure {
    type: sum
    sql: ${tot_outstanding} ;;
  }

  measure: tot_revenue_measure {
    type: sum
    sql: ${revenue} ;;
  }

  measure: count {
    hidden: yes
    type: count
    drill_fields: [market_name]
  }

  measure: market_dso_calculation {
    type: number
    sql: ROUND((${tot_outstanding_measure} / CASE WHEN ${tot_revenue_measure} = 0 THEN 1 ELSE ${tot_revenue_measure} END)*180) ;;
    value_format: "0"
    link: {
      label: "View DSO History"
      url: "https://equipmentshare.looker.com/looks/14?f[collector_customer_assignments.final_collector]={{ _filters['collector_customer_assignments.final_collector'] | url_encode }}&f[markets.name]={{ _filters['markets.name'] | url_encode }}&toggle=det"
    }
  }
}
