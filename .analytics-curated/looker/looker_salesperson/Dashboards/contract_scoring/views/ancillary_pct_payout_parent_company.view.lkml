view: ancillary_pct_payout_parent_company {

  sql_table_name: RATE_ACHIEVEMENT.ANCILLARY_PCT_PAYOUT_PARENT_COMPANY ;;
#Moves derived table to snowflake
  dimension: pkey {
    type: string
    primary_key: yes
    hidden: yes
    sql: CONCAT(${TABLE}.invoice_date,COALESCE(${TABLE}.min_ancillary, -9999),COALESCE(${TABLE}.max_ancillary,9999))  ;;
  }


  dimension_group: invoice_date {
    type: time
    timeframes: [
      quarter,
      year
    ]
    sql: CAST(${TABLE}."INVOICE_DATE" AS TIMESTAMP_NTZ) ;;
  }


  dimension: min_ancillary {
    type: number
    sql: ${TABLE}.min_ancillary ;;
  }

  dimension: max_ancillary {
    type: number
    sql: ${TABLE}.max_ancillary ;;
  }

  dimension: ancillary_multiplier {
    type: number
    sql: ${TABLE}.ancillary_multiplier ;;
  }

  dimension: pct_total_na {
    type: number
    sql: ${TABLE}.pct_total_na ;;
  }

  dimension: payout {
    type: number
    sql: ${TABLE}.payout ;;
  }

  dimension: gross_profit {
    type: number
    sql: ${TABLE}.gp_sum ;;
  }

  dimension: rental_revenue {
    type: number
    sql: ${TABLE}.rev_sum ;;
  }

  dimension: gross_profit_payout {
    type: number
    sql: ${TABLE}.gross_profit_payout ;;
  }


  measure: gross_profit_payout_sum {
    type: sum
    sql: ${TABLE}.gross_profit_payout ;;
  }

  measure: payout_sum {
    type: sum
    sql: ${TABLE}.payout ;;
  }

#
#   dimension: lifetime_orders {
#     description: "The total number of orders for each user"
#     type: number
#     sql: ${TABLE}.lifetime_orders ;;
#   }
#
#   dimension_group: most_recent_purchase {
#     description: "The date when each user last ordered"
#     type: time
#     timeframes: [date, week, month, year]
#     sql: ${TABLE}.most_recent_purchase_at ;;
#   }
#
#   measure: total_lifetime_orders {
#     description: "Use this for counting lifetime orders across many users"
#     type: sum
#     sql: ${lifetime_orders} ;;
#   }
}
