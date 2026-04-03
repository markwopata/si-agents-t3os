view: internal_rentals {
  derived_table: {
    sql: select PK_RENTAL_ID as RENTAL_ID,
      FK_ASSET_ID as ASSET_ID,
      FK_RENTAL_TYPE_ID as RENTAL_TYPE_ID,
      FK_ORDER_ID as ORDER_ID,
      INVOICE_NO,
      TIMESTAMP_START as RENTAL_START,
      TIMESTAMP_END as RENTAL_END,
      from financial_systems.auditing_gold.internal_rentals
      order by timestamp_start desc
      ;;
  }
  dimension: RENTAL_ID {
    type: number
    sql: ${TABLE}.RENTAL_ID ;;
  }

  dimension: ASSET_ID {
    type: number
    sql: ${TABLE}.ASSET_ID ;;
  }

  dimension: RENTAL_TYPE_ID {
    type: number
    sql: ${TABLE}.RENTAL_TYPE_ID;;
  }

  dimension: ORDER_ID {
    type: number
    sql: ${TABLE}.ORDER_ID ;;
  }

  dimension: INVOICE_NO {
    type: string
    sql: ${TABLE}.INVOICE_NO ;;
  }


  dimension: RENTAL_START {
    type: date
    sql: ${TABLE}.RENTAL_START ;;
  }

  dimension: RENTAL_END {
    type: date
    sql: ${TABLE}.RENTAL_END ;;
  }

}
