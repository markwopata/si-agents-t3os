view: billing_company_preferences {
    sql_table_name: "ES_WAREHOUSE"."PUBLIC"."BILLING_COMPANY_PREFERENCES" ;;


dimension: billing_company_preferences_id {
    type: string
    sql: ${TABLE}."BILLING_COMPANY_PREFERENCES_ID" ;;
}

  dimension: company_id {
    type: string
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension_group: date_created {
    type: time
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension_group: date_updated {
    type: time
    sql: ${TABLE}."DATE_UPDATED" ;;
  }

  dimension: rental_billing_cycle_strategy {
    type: string
    sql: ${TABLE}."RENTAL_BILLING_CYCLE_STRATEGY" ;;
  }

  dimension: rental_billing_cycle_strategy_formatted {
    type: string
    sql: case when ${rental_billing_cycle_strategy} = 'twenty_eight_day_cycle' then 'Twenty-eight Day Cycle'
    when ${rental_billing_cycle_strategy} = 'thirty_day_cycle' then 'Thirty Day Cycle'
    when ${rental_billing_cycle_strategy} = 'first_of_month' then 'First of Month' end ;;
  }

}
