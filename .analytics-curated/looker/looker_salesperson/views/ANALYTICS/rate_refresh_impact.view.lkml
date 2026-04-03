view: rate_refresh_impact {
  sql_table_name: "ANALYTICS"."RATE_ACHIEVEMENT"."RATE_REFRESH_IMPACT" ;;

  dimension: amount {
    type: number
    sql: ${TABLE}."AMOUNT" ;;
  }
  dimension: billing_type {
    type: string
    sql: ${TABLE}."BILLING_TYPE" ;;
  }
  dimension: branch_id {
    type: number
    sql: ${TABLE}."BRANCH_ID" ;;
  }
  dimension_group: company_rates_expiration {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."COMPANY_RATES_EXPIRATION_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: company_contract_expiration {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."COMPANY_CONTRACT_EXPIRATION_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }
  dimension: company_rate {
    type: number
    sql: ${TABLE}."COMPANY_RATE" ;;
  }
  dimension: company_rates {
    type: string
    sql: ${TABLE}."COMPANY_RATES" ;;
  }
  dimension: company_rate_below_floor {
    type: yesno
    sql: ${TABLE}."COMPANY_RATE_BELOW_FLOOR" ;;
  }
  dimension: company_rate_current {
    type: yesno
    sql: ${TABLE}."COMPANY_RATE_CURRENT" ;;
  }
  dimension: company_rate_protected {
    type: yesno
    sql: ${TABLE}."COMPANY_RATE_PROTECTED" ;;
  }
  dimension: current_rate_below_floor {
    type: yesno
    sql: ${TABLE}."CURRENT_RATE_BELOW_FLOOR" ;;
  }
  dimension: cycle_length {
    type: number
    sql: ${TABLE}."CYCLE_LENGTH" ;;
  }
  dimension: effective_four_week_rate {
    type: number
    sql: ${TABLE}."EFFECTIVE_FOUR_WEEK_RATE" ;;
  }
  dimension: effective_rate_below_floor {
    type: yesno
    sql: ${TABLE}."EFFECTIVE_RATE_BELOW_FLOOR" ;;
  }
  dimension: equipment_class_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
  }
  dimension: invoice_id {
    type: number
    sql: ${TABLE}."INVOICE_ID" ;;
  }
  dimension: line_item_id {
    type: number
    primary_key: yes
    sql: ${TABLE}."LINE_ITEM_ID" ;;
  }
  dimension_group: location_rates_expiration {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."LOCATION_RATES_EXPIRATION_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: location_contract_expiration {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."LOCATION_CONTRACT_EXPIRATION_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension: location_rate {
    type: number
    sql: ${TABLE}."LOCATION_RATE" ;;
  }
  dimension_group: negotiated_rate_expiration {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."NEGOTIATED_RATE_EXPIRATION_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: negotiated_contract_expiration {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."NEGOTIATED_CONTRACT_EXPIRATION_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension: location_rate_below_floor {
    type: yesno
    sql: ${TABLE}."LOCATION_RATE_BELOW_FLOOR" ;;
  }
  dimension: location_rate_current {
    type: yesno
    sql: ${TABLE}."LOCATION_RATE_CURRENT" ;;
  }
  dimension: location_rate_protected {
    type: yesno
    sql: ${TABLE}."LOCATION_RATE_PROTECTED" ;;
  }
  dimension: proposed_floor {
    type: number
    sql: ${TABLE}."PROPOSED_FLOOR" ;;
  }
  dimension: rental_id {
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
  }
  dimension: rate_expires_before_rental_ends {
    type: yesno
    sql: ${TABLE}."RATE_EXPIRES_BEFORE_RENTAL_ENDS" ;;
  }
  dimension: proposed_rates {
    type: string
    sql: ${TABLE}."PROPOSED_RATES" ;;
  }
  dimension: company_class_revenue_ytd {
    type: number
    sql: ${TABLE}."YTD_REVENUE" ;;
  }

  dimension: company_or_location_rate_current  {
    type: yesno
    sql: case when ${company_rate_current} = True or ${location_rate_current} = True then True else False end ;;
  }

  dimension: company_or_location_rate_protected  {
    type: yesno
    sql: case when ${company_rate_protected} = True or ${location_rate_protected} = True then True else False end ;;
  }

  dimension: company_or_location_rate_below_floor {
    type: yesno
    sql: case when ${current_rate_below_floor} = True then True else False end ;;
  }

  dimension: company_or_location_rate_below_new_floor {
    type: yesno
    sql: case when ${company_rate_below_floor} = True or ${location_rate_below_floor} = True then True else False end ;;
  }

  measure: rental_revenue {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd_0
  }

  measure: rental_revenue_under_negotiated_rates {
    type: sum
    sql: ${amount};;
    filters: [company_or_location_rate_current: "Yes"]
  }

  measure: rental_revenue_below_current_floor {
    type: sum
    sql: ${amount};;
    filters: [current_rate_below_floor: "Yes"]
  }

  measure: rental_revenue_below_new_floor {
    type: sum
    sql: ${amount};;
    filters: [company_or_location_rate_below_floor: "Yes"]
  }

  measure: rental_revenue_needing_increase {
    type: sum
    sql: ${amount};;
    filters: [effective_rate_below_floor: "Yes"]
  }

  measure: count {
    type: count
  }
}
