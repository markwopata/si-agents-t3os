view: sales_rep_main_market {
  derived_table: {
    sql: with pull_rep_market as (
      select
        final_market,
        salesperson,
        salesperson_user_id,
        sum(case when final_market is not null then 1 else 0 end) as test_column
      from
        rateachievement_points
      group by
        final_market,
        salesperson,
        salesperson_user_id
      )
      select
        final_market as main_market,
        salesperson,
        salesperson_user_id
      from
        pull_rep_market
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: main_market {
    type: string
    sql: ${TABLE}."MAIN_MARKET" ;;
  }

  dimension: salesperson {
    type: string
    sql: ${TABLE}."SALESPERSON" ;;
  }

  dimension: salesperson_user_id {
    type: number
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  }

  dimension: is_main_market {
    type: yesno
    sql: ${salesperson_user_id} = ${users.user_id}  AND ${market_region_xwalk.market_name} = ${main_market} ;;
  }

  set: detail {
    fields: [main_market, salesperson, salesperson_user_id]
  }
}
