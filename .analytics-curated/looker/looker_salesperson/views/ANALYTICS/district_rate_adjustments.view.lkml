view: district_rate_adjustments {
  sql_table_name: "PUBLIC"."DISTRICT_RATE_ADJUSTMENTS";;


  dimension: achieved_rate {
    type: number
    sql: ${TABLE}."ACHIEVED_RATE" ;;
  }

  dimension: adj_month_benchmark {
    type: number
    sql: ${TABLE}."ADJ_MONTH_BENCHMARK" ;;
  }

  dimension: adj_month_floor {
    type: number
    sql: ${TABLE}."ADJ_MONTH_FLOOR" ;;
  }

  dimension: adj_month_online {
    type: number
    sql: ${TABLE}."ADJ_MONTH_ONLINE" ;;
  }

  dimension: avg_pct_discount {
    type: number
    sql: ${TABLE}."AVG_PCT_DISCOUNT" ;;
  }

  dimension: below_floor_count {
    type: number
    sql: ${TABLE}."BELOW_FLOOR_COUNT" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: equipment_class {
    type: string
    sql: ${TABLE}."EQUIPMENT_CLASS" ;;
  }

  dimension: equipment_class_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
  }

  dimension: invoice_count {
    type: number
    sql: ${TABLE}."INVOICE_COUNT" ;;
  }

  dimension: month_benchmark {
    type: number
    sql: ${TABLE}."MONTH_BENCHMARK" ;;
  }

  dimension: month_floor {
    type: number
    sql: ${TABLE}."MONTH_FLOOR" ;;
  }

  dimension: month_online {
    type: number
    sql: ${TABLE}."MONTH_ONLINE" ;;
  }

  dimension: pct_adjustment {
    type: number
    sql: ${TABLE}."PCT_ADJUSTMENT" ;;
  }

  dimension: total_revenue {
    type: number
    sql: ${TABLE}."TOTAL_REVENUE" ;;
  }

  # A measure is a field that uses a SQL aggregate function. Here are defined sum and average
  # measures for this dimension, but you can also add measures of many different aggregates.
  # Click on the type parameter to see all the options in the Quick Help panel on the right.

  measure: total_total_revenue {
    type: sum
    sql: ${total_revenue} ;;
  }

  measure: average_total_revenue {
    type: average
    sql: ${total_revenue} ;;
  }

  #dimension: submit_spend_receipt_autofill {
  #  type: string
  #  html: <font color="blue "><u><a href ="https://docs.google.com/forms/d/e/1FAIpQLSfpAR6MGq9OrnnwL9dJz8qZIelo-0gL_W-Guagp9xwoAykUVQ/viewform?usp=pp_url&entry.1164859533={{  _user_attributes['name'] }}&entry.837344666=Credit+Card&entry.1077598267={{ cc_and_fuel_spend_all.transaction_amount._value }}&entry.1579787528={{cc_and_fuel_spend_all.transaction_date_date._value}}&entry.130892990={{  _user_attributes['email'] }}"target="_blank">Submit Credit Card Receipt</a></font></u> ;;
  #  sql: ${transaction_id} ;;
  #}

  measure: count {
    type: count
    drill_fields: []
  }
}
