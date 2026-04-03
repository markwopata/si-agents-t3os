
view: actively_renting_customers {
  derived_table: {
    sql: select o.market_id,
             xw.market_name,
             count(distinct c.company_id) as actively_renting_customers
      from ES_WAREHOUSE.PUBLIC.ORDERS o
      left join ES_WAREHOUSE.PUBLIC.RENTALS r on o.order_id = r.order_id
      left join ANALYTICS.PUBLIC.MARKET_REGION_XWALK xw on o.market_id = xw.market_id
      left join ES_WAREHOUSE.PUBLIC.USERS u on o.user_id = u.user_id
      left join ES_WAREHOUSE.PUBLIC.COMPANIES c on u.company_id = c.company_id
      where r.rental_status_id = 5 and xw.market_name is not null
      group by o.market_id,
               xw.market_name ;;
  }

  measure: count {
    type: count
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  measure: actively_renting_customers {
    type: number
    sql: ${TABLE}."ACTIVELY_RENTING_CUSTOMERS" ;;
    drill_fields: [actively_renting_customers_drill.customer, actively_renting_customers_drill.total_count_of_current_rentals]
  }
}
