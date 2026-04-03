view: all_hands_data {
  derived_table: { sql:
    select
    i.company_id,
    l.gl_billing_approved_date as billing_approved_date,
    l.line_item_type_id,
    l.amount
    from es_warehouse.public.invoices i
    left join analytics.public.v_line_items l on i.invoice_id = l.invoice_id
    where l.line_item_type_id not in (17,19,21,35,36,39,40,41,42,45,47,48,76,82,83,85,87);;
  }

dimension: company_id {
  primary_key: yes
  type: number
  sql: ${TABLE}."COMPANY_ID" ;;
}

dimension_group: billing_approved {
  type: time
  timeframes: [
    raw,
    time,
    date,
    week,
    month,
    quarter,
    year
  ]
  sql: CAST(${TABLE}."BILLING_APPROVED_DATE" AS TIMESTAMP_NTZ) ;;
}

dimension: line_item_type_id {
  type: number
  sql: ${TABLE}."LINE_ITEM_TYPE_ID" ;;
}

dimension: amount {
  type: number
  sql: ${TABLE}."AMOUNT" ;;
}

measure: customer_count {
  type: count_distinct
  sql: ${company_id} ;;
}

dimension: rental {
  type: yesno
  sql: ${line_item_type_id} in (6,8,108,109) ;;
}

dimension: track {
  type: yesno
  sql: ${line_item_type_id} in (30,31,32,33,34) ;;
}

dimension: service {
  type: yesno
  sql: ${line_item_type_id} in (13,20) ;;
}

dimension: parts {
  type: yesno
  sql: ${line_item_type_id} in (11,12,49) ;;
}

dimension: equipment {
  type: yesno
  sql: ${line_item_type_id} in (24,50,80,81) ;;
}

measure: total_revenue_current_month {
  type: sum
  sql: ${amount};;
  value_format_name: usd_0
  filters: [billing_approved_current_month: "Yes"]
}

measure: total_revenue_last_month {
  type: sum
  sql: ${amount} ;;
  value_format_name: usd_0
  filters: [billing_approved_last_month: "Yes"]
}

measure: total_revenue_current_year {
  type: sum
  sql: ${amount} ;;
  value_format_name: usd_0
  filters: [billing_approved_current_year: "Yes"]
}

measure: total_revenue_last_year {
  type: sum
  sql: ${amount} ;;
  value_format_name: usd_0
  filters: [billing_approved_last_year: "Yes"]
}

measure: total_customers_last_month {
  type: count_distinct
  sql: ${company_id} ;;
  filters: [billing_approved_last_month: "Yes"]
  }

measure: total_customers_current_month {
  type: count_distinct
  sql: ${company_id} ;;
  filters: [billing_approved_current_month: "Yes"]
  }

measure: total_customers_last_year {
  type: count_distinct
  sql: ${company_id} ;;
  filters: [billing_approved_last_year: "Yes"]
}

measure: total_customers_current_year {
  type: count_distinct
  sql: ${company_id} ;;
  filters: [billing_approved_current_year: "Yes"]
  }

dimension:  billing_approved_last_month {
  type: yesno
  sql: date_part(month,${billing_approved_raw})  = date_part(month,(date_trunc('month', current_date - interval '1 month')))
        and date_part(year,${billing_approved_raw}) = date_part(year,(date_trunc('year', current_date - interval '1 month'))) ;;
}

dimension:  billing_approved_current_month {
  type: yesno
  sql: date_part(day,${billing_approved_raw}) <= date_part(day,(date_trunc('day', current_date)))
        and date_part(month,${billing_approved_raw})  = date_part(month,(date_trunc('month', current_date)))
        and date_part(year,${billing_approved_raw}) = date_part(year,(date_trunc('year', current_date))) ;;
  }

dimension:  billing_approved_last_year {
  type: yesno
  sql: date_part(year,${billing_approved_raw}) = date_part(year,(date_trunc('year', current_date - interval '1 year'))) ;;
  }

dimension:  billing_approved_current_year {
  type: yesno
  sql: date_part(year,${billing_approved_raw}) = date_part(year,(date_trunc('year', current_date))) ;;
  }
}
