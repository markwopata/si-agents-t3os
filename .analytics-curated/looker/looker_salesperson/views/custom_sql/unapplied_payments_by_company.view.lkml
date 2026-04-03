view: unapplied_payments_by_company {
    derived_table: {
     sql:   SELECT company_id,
                   payment_id,
                   amount_remaining
            FROM es_warehouse.public.payments p
            WHERE amount_remaining > 0
       ;;
   }

  dimension: company_id {
    description: "Unique ID for each company"
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
    value_format_name: id
  }

  dimension: payment_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."PAYMENT_ID" ;;
    value_format_name: id
  }

  dimension: amount_remaining {
    description: "The amount remaining from received payments"
    type: number
    sql: ${TABLE}."AMOUNT_REMAINING" ;;
    value_format_name: usd_0
  }

  measure: unapplied_payments {
    description: "Total amount of payments received but unapplied to outstanding invoices"
    type: sum
    sql: ${amount_remaining} ;;
    value_format_name: usd_0
    drill_fields: [payment_id, amount_remaining]
  }

}
