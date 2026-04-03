view: max_invoice_and_rental_id {
  derived_table: {
    sql: select max(rental_id) rental_id,
          max(invoice_id) invoice_id
        from
          ES_WAREHOUSE.PUBLIC.global_line_items
        where
          line_item_type_id = 8
          and domain_id = 0 --US data
        group by
          rental_id,
          invoice_id
        union
        select max(rental_id) rental_id,
          max(invoice_id) invoice_id
        from
          ES_WAREHOUSE.PUBLIC.global_line_items
        where
          line_item_type_id = 1
          and domain_id = 1 --global data
        group by
          rental_id,
          invoice_id
 ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: rental_id {
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
  }

  dimension: invoice_id {
    type: number
    sql: ${TABLE}."INVOICE_ID" ;;
  }

  set: detail {
    fields: [rental_id, invoice_id]
  }

  dimension: same_rental_ids {
    type: yesno
    sql: ${rental_id} = ${rentals.rental_id} ;;
  }
}
