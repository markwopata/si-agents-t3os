view: cash_balances_by_entity {
  derived_table: {
    sql: select *
    from analytics.treasury.cash_balances_by_entity_history as cbe
   where bank_id is not null
   and timestamp = (select max(timestamp) from analytics.treasury.cash_balances_by_entity_history)
   and date::date >= '2022-08-01'
    ;;
  }

  dimension: bank_name {
    type: string
    sql: ${TABLE}.BANK_NAME ;;
  }

  dimension: date {
    type: date
    sql: ${TABLE}.DATE ;;
  }


  measure: bank_cash {
    type: sum
    value_format: "$#;($#);-"
    sql: case when ${bank_name} is null then 0 else ${TABLE}.COMPOSITEBALANCECONVERTED/1000000 end;;
  }

  measure: total_cash {
    type: sum
    sql: ${TABLE}.COMPOSITEBALANCECONVERTED  ;;
  }




  }
