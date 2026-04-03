
view: salesrep_cash_collection_goal_drill {
  derived_table: {
    sql: select
          cap.salesperson_user_id,
          cap.invoice_no,
          cap.payment_amount,
          c.name as company_name
      from
          analytics.treasury.collections_actuals_payments cap
          join es_warehouse.public.invoices i on cap.invoice_no = i.invoice_no
          join es_warehouse.public.orders o on i.order_id = o.order_id
          join es_warehouse.public.users u on u.user_id = o.user_id
          join es_warehouse.public.companies c on c.company_id = u.company_id
      where
          (
          ('salesperson' = {{ _user_attributes['department'] }} AND u.deleted = 'No' AND u.email_address ILIKE '{{ _user_attributes['email'] }}')
          )
          OR
          (
          ('salesperson' != {{ _user_attributes['department'] }}
          AND
          ('developer' = {{ _user_attributes['department'] }}
          OR 'god view' = {{ _user_attributes['department'] }}
          OR 'managers' = {{ _user_attributes['department'] }}
          OR 'collectors' = {{ _user_attributes['department'] }})
          )
          ) ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: salesperson_user_id {
    type: number
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  }

  dimension: invoice_no {
    type: string
    sql: ${TABLE}."INVOICE_NO" ;;
  }

  dimension: payment_amount {
    type: number
    sql: ${TABLE}."PAYMENT_AMOUNT" ;;
  }

  dimension: company_name {
    label: "Customer"
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  measure: total_collected {
    type: sum
    sql: ${payment_amount} ;;
    value_format_name: usd_0
  }

  set: detail {
    fields: [
      salesperson_user_id,
      invoice_no,
      payment_amount,
      company_name
    ]
  }
}
