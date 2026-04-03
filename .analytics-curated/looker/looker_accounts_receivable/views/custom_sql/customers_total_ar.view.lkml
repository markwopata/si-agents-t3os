view: customers_total_ar {
  derived_table: {
    # datagroup_trigger: Every_Two_Hours_Update
    sql: select
        c.company_id,
        sum(case when i.owed_amount is not null and i.owed_amount > 0.0 then i.owed_amount ELSE i.billed_amount end) as amount
      FROM
      ES_WAREHOUSE.public.orders o
      LEFT JOIN ES_WAREHOUSE.public.invoices i ON o.order_id = i.order_id
      LEFT JOIN ES_WAREHOUSE.public.users u ON o.user_id = u.user_id
      LEFT JOIN ES_WAREHOUSE.public.companies c ON u.company_id = c.company_id
      where
        paid = false
        and billing_approved = true
      group by
        c.company_id
 ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: company_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: amount {
    type: number
    sql: ${TABLE}."AMOUNT" ;;
  }

  measure: total_ar_amount {
    type: sum
    sql: ${amount} ;;
  }

  set: detail {
    fields: [company_id, amount]
  }
}
