
view: weekly_ad_hoc_quotes {
  derived_table: {
    sql: with salesreps_first_usage as (
          select
              sales_rep_id,
              branch_id,
              MIN(TIME_SLICE(q.created_date, 1, 'WEEK', 'START'))::date AS "STARTOFWEEK"
          from
              quotes.quotes.quote q
          where
              convert_timezone('America/Chicago', q.created_date) BETWEEN date('2023-07-31') AND current_date
          group by
              sales_rep_id,
              branch_id
      )
      select
          m.name as branch,
          TIME_SLICE(q.created_date, 1, 'WEEK', 'START')::date AS "STARTOFWEEK",
          count(distinct q.id) as number_of_quotes,
          count(distinct(sru.sales_rep_id)) as unique_new_users,
          count(distinct order_id) as orders
      from
          quotes.quotes.quote q
      left join es_warehouse.public.markets m on m.market_id = q.branch_id
      left join salesreps_first_usage sru on sru.STARTOFWEEK = TIME_SLICE(q.created_date, 1, 'WEEK', 'START')::date AND sru.branch_id = q.branch_id
      where
          convert_timezone('America/Chicago', q.created_date) between date('2023-07-31') AND current_date
      group by
          1,2 ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: branch {
    type: string
    sql: ${TABLE}."BRANCH" ;;
  }

  dimension: startofweek {
    label: "Week"
    type: date
    sql: ${TABLE}."STARTOFWEEK" ;;
  }

  dimension: number_of_quotes {
    type: number
    sql: ${TABLE}."NUMBER_OF_QUOTES" ;;
  }

  dimension: unique_new_users {
    type: number
    sql: ${TABLE}."UNIQUE_NEW_USERS" ;;
  }

  dimension: orders {
    type: number
    sql: ${TABLE}."ORDERS" ;;
  }

  measure: total_quotes {
    type: sum
    sql: coalesce(${number_of_quotes},0) ;;
  }

  measure: total_unique_new_users{
    type: sum
    sql: coalesce(${unique_new_users},0) ;;
  }

  measure: total_orders {
    type: sum
    sql: coalesce(${orders},0) ;;
  }

  set: detail {
    fields: [
        branch,
  startofweek,
  total_quotes,
  unique_new_users,
  orders
    ]
  }
}
