view: salesperson_to_market {
  derived_table: {
    # datagroup_trigger: 6AM_update
    sql: select
        distinct(salesperson_user_id),
        salesperson,
        final_market
      from
        rateachievement_points rp
 ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: salesperson_user_id {
    type: number
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  }

  dimension: salesperson {
    type: string
    sql: ${TABLE}."SALESPERSON" ;;
  }

  dimension: final_market {
    type: string
    sql: ${TABLE}."FINAL_MARKET" ;;
  }

  dimension: full_name_with_id {
    type: string
    sql: concat(${salesperson}, ' - ',${salesperson_user_id}) ;;
  }

  measure: final_market_distinct_count {
    type: count_distinct
    sql: ${final_market} ;;
    description: "Used to toggle final market name on salesperson dashboard"
  }

  dimension: is_main_market {
    type: yesno
    sql: ${salesperson_user_id} = ${users.user_id}  AND ${market_region_xwalk.market_name} = ${final_market} ;;
  }

  set: detail {
    fields: [salesperson_user_id, salesperson, final_market]
  }
}
