
view: branch_cash_collection_goals_drill {
  derived_table: {
    sql: select
          cap.branch_id,
          cap.branch_name,
          mrx.region_name,
          mrx.district,
          mrx.region_district,
          cap.salesperson_user_id,
          cap.invoice_no,
          cap.payment_amount,
          c.name as company_name
      from
          analytics.treasury.collections_actuals_payments cap
          join analytics.public.market_region_xwalk mrx on mrx.market_id = cap.branch_id
          join es_warehouse.public.invoices i on cap.invoice_no = i.invoice_no
          join es_warehouse.public.orders o on i.order_id = o.order_id
          join es_warehouse.public.users u on u.user_id = o.user_id
          join es_warehouse.public.companies c on c.company_id = u.company_id
      where
          (
          'developer' = {{ _user_attributes['department'] }}
          OR 'god view' = {{ _user_attributes['department'] }}
          OR 'managers' = {{ _user_attributes['department'] }}
          OR 'collectors' = {{ _user_attributes['department'] }}
          ) ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: branch_id {
    type: string
    sql: ${TABLE}."BRANCH_ID" ;;
  }

  dimension: branch_name {
    type: string
    sql: ${TABLE}."BRANCH_NAME" ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: region_district {
    type: string
    sql: ${TABLE}."REGION_DISTRICT" ;;
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
        branch_id,
  branch_name,
  region_name,
  district,
  region_district,
  salesperson_user_id,
  invoice_no,
  payment_amount,
  company_name
    ]
  }
}
