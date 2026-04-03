view: test {
  derived_table: {
    sql: select
        invoice_id,
        branch_id
      from
        line_items
      where
        line_item_type_id in (13,25,26)
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: invoice_id {
    type: number
    sql: ${TABLE}."invoice_id" ;;
  }

  dimension: branch_id {
    type: number
    sql: ${TABLE}."branch_id" ;;
  }

  set: detail {
    fields: [invoice_id, branch_id]
  }
}
