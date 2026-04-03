view: labor_cost_vendor_level {
##OUT OF DATE DO NOT USE
  sql_table_name: "ANALYTICS"."SERVICE"."LABOR_COSTS_SCORECARD" ;;

  dimension: primary_key {
    type: string
    primary_key: yes
    sql:${TABLE}.primary_key ;;
    # sql: CAST(
    #       CONCAT(
    #       ${TABLE}.company_purchase_order_line_item_id,
    #       ${TABLE}.vendorid)
    #       as VARCHAR) ;;
  }

  dimension: vendorid {
    type: string
    sql: ${TABLE}.vendorid ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}.vendor ;;
  }

  dimension_group: date_completed {
    type: time
    timeframes: [raw,date,time,week,month,quarter,year]
    sql: ${TABLE}.date_completed ;;
  }

  dimension: asset_id {
    #primary_key: yes
    type: number
    sql: ${TABLE}.asset_id ;;
  }

  measure: total_hours {
    type: sum
    sql: ${TABLE}.total_hours ;;
  }

  measure: labor_cost {
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}.labor_cost ;;
  }

  measure: parts_cost {
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}.parts_cost ;;
  }

  measure: cost_of_ownership {
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}.cost_of_ownership ;;
  }

  # -------------------- rolling 30 days section --------------------
  dimension:  last_30_days{
    type: yesno
    sql:  ${TABLE}.date_completed <= current_date AND ${TABLE}.date_completed >= (current_date - INTERVAL '30 days')
      ;;
  }

  measure: 30_day_cost {
    type: sum
    filters: [last_30_days: "No"]
    value_format_name:usd
    value_format: "$#,##0"
    sql: ${TABLE}.labor_cost ;;
  }

  measure: 30_day_cost_of_ownership {
    type: sum
    filters: [last_30_days: "No"]
    value_format_name:usd
    value_format: "$#,##0"
    sql: ${TABLE}.cost_of_ownership;;
  }


  # -------------------- end rolling 30 days section --------------------

  }
