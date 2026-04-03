view: memo_months {
  derived_table: {
    sql: select distinct
              date_trunc('month',billing_approved_date) as month
          ,   dateadd(month, -12, date_trunc('month',billing_approved_date)) as ytd_start_month
      from es_warehouse.public.invoices
      where cast(billing_approved_date as date) is not null
      and date_trunc('month',billing_approved_date) >= '2023-01-01'
      and date_trunc('month',billing_approved_date) < date_trunc('month', current_date);;
  }


  dimension: month {
    type: date_month
    convert_tz: no
    sql: ${TABLE}."MONTH" ;;
  }

  dimension: ytd_start_month {
    type: date_month
    convert_tz: no
    sql: ${TABLE}."YTD_START_MONTH" ;;
  }

  set: detail {
    fields: [
      month,
      ytd_start_month
    ]
  }
}
