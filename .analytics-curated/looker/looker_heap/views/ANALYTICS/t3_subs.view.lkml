view: t3_subs {
  derived_table: {
    sql: select
        t3.month::date as invoiced_month
        , t3.company_id
        , c.name as company_name
        , row_number() over (partition by t3.company_id order by t3.month::date asc) as rnk
      from analytics.analytics.t_3_invoice_company_ids t3
      join es_warehouse.public.companies c on t3.company_id = c.company_id;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension_group: invoiced_month {
    type: time
    sql: ${TABLE}."INVOICED_MONTH" ;;
  }

  dimension: company_id {
    type: string
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: rnk {
    type: number
    sql: ${TABLE}."RNK" ;;
  }
  measure: distinct_companies {
    type: count_distinct
    sql_distinct_key: ${invoiced_month_month} ;;
    sql: ${company_id} ;;
  }

  measure: customer_tenure_months {
    type: max
    sql: ${rnk} ;;
  }

  dimension: is_vip_customer {
    label: "VIP Customer"
    type: yesno
    sql:
    CASE WHEN ${TABLE}.COMPANY_ID IN (50, 8935, 2968, 7978, 5437, 5658, 24008, 11674, 60574, 10924)
         THEN TRUE
         ELSE FALSE
    END
  ;;
  }

  set: detail {
    fields: [
      invoiced_month_month,
      invoiced_month_year,
      company_id,
      rnk
    ]
  }
}
