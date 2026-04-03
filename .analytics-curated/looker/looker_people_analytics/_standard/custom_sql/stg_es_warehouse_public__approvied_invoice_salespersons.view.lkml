view: stg_es_warehouse_public__approvied_invoice_salespersons {
  derived_table: {
    sql: select ais.*,
    concat(ais.invoice_id,'|',ais.salesperson_id) as invoice_salesperson_key,
    count(iff(ais.salesperson_type_id = 2, ais.salesperson_type_id, null)) over (partition by ais.invoice_id) as secondary_rep_count,
    case when ais.salesperson_type_id = 1 and secondary_rep_count = 0 then 1
    when ais.salesperson_type_id = 1 and secondary_rep_count >= 1 then .5
    when ais.salesperson_type_id = 2 and secondary_rep_count = 1 then .5
    else .5/secondary_rep_count end as revenue_split,
    (revenue_split * i.billed_amount) as revenue,
    sum(revenue) over (partition by ais.salesperson_id) as total_revenue,
    count(distinct(ais.invoice_id)) over (partition by ais.salesperson_id) as invoice_count,
    (total_revenue/datediff(months,dateadd(day,{{ invoice_date._parameter_value }},getdate()),current_date))/invoice_count as average_revenue
    from ANALYTICS.INTACCT_MODELS.STG_ES_WAREHOUSE_PUBLIC__APPROVED_INVOICE_SALESPERSONS ais
    left join ES_WAREHOUSE.PUBLIC.INVOICES i on ais.invoice_id = i.invoice_id
    where i.invoice_date >= dateadd(day,{{ invoice_date._parameter_value }},getdate()) and i.invoice_date <= getdate();;
  }
  dimension_group: _es_update_timestamp {
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
    sql: ${TABLE}."_ES_UPDATE_TIMESTAMP";;
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
    sql: ${TABLE}."BILLING_APPROVED_DATE";;
  }
  dimension: invoice_salesperson_key {
    primary_key: yes
    value_format_name: id
    type: string
    sql: ${TABLE}."INVOICE_SALESPERSON_KEY" ;;
  }
  dimension: invoice_id {
    value_format_name: id
    type: string
    sql: ${TABLE}."INVOICE_ID" ;;
  }
  dimension: sales_person_type {
    type: string
    sql: ${TABLE}."SALES_PERSON_TYPE" ;;
  }
  dimension: salesperson_id {
    value_format_name: id
    type: string
    sql: ${TABLE}."SALESPERSON_ID" ;;
  }
  dimension: salesperson_type_id {
    value_format_name: id
    type: number
    sql: ${TABLE}."SALESPERSON_TYPE_ID" ;;
  }
  dimension: secondary_rep_count {
    type: number
    sql: ${TABLE}."SECONDARY_REP_COUNT" ;;
  }
  dimension: revenue_split {
    type: number
    sql: ${TABLE}."REVENUE_SPLIT" ;;
  }
  dimension: revenue {
    value_format: "$#,##0.00"
    type: number
    sql: ${TABLE}."REVENUE" ;;
  }
  dimension: total_revenue {
    value_format: "$#,##0.00"
    type: number
    sql: ${TABLE}."TOTAL_REVENUE" ;;
  }
  dimension: average_revenue {
    value_format: "$#,##0.00"
    type: number
    sql: ${TABLE}."AVERAGE_REVENUE" ;;
  }
  measure: count {
    type: count
  }
  parameter: invoice_date {
    type: string
    default_value: "-1000000"
    allowed_value: {
      label: "Past 90 Days"
      value: "-90"
    }
    allowed_value: {
      label: "Past 180 Days"
      value: "-180"
    }
    allowed_value: {
      label: "Past Year"
      value: "-365"
    }
    allowed_value: {
      label: "Past Two Years"
      value: "-730"
    }
  }
}
