view: max_invoice_and_rental_id {
  derived_table: {
    # datagroup_trigger: Every_Two_Hours_Update
    sql: select max(rental_id) rental_id,
          max(invoice_id) invoice_id
        from
          ANALYTICS.PUBLIC.v_line_items
        where
          line_item_type_id in (6,8,108,109)
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
}
