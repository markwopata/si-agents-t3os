view: commission_lookup {

  derived_table: {
    sql:
      select COMMISSION_ID,
             LINE_ITEM_ID,
             SALESPERSON_USER_ID,
             INVOICE_NO,
             amount,
             RENTAL_CLASS_ID_FROM_RENTAL,
             MARKET_ID,
             FLOOR_RATE,
             BOOK_RATE,
             OVERRIDE_RATE,
             COMMISSION_RATE
      from analytics.commission_dbt.COMMISSION_FINAL_ALL
      where ORDER_ID = 4946123
        and LINE_ITEM_TYPE_ID = 8
      order by LINE_ITEM_ID ;;
  }

  dimension: rental_class_id_from_rental {
    type: number
    sql: ${TABLE}.RENTAL_CLASS_ID_FROM_RENTAL ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}.MARKET_ID ;;
  }

  dimension: floor_rate {
    type: number
    sql: ${TABLE}.FLOOR_RATE ;;
    value_format_name: usd

    link: {
      url: "/dashboards/2462?Equipment+Class+ID={{ rental_class_id_from_rental._value }}&Branch+ID={{ market_id._value }}&Rate+Type=Floor"
    }
  }
}
