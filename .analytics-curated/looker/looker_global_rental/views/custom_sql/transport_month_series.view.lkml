view: transport_month_series {
  derived_table: {
    sql:
    with month_date_series as (
    select distinct date_trunc('month', series::date) as month_date
        from table(es_warehouse.public.generate_series(
                                  dateadd(month, -5, current_date)::timestamp_tz,
                                  dateadd(month, 1, current_date)::timestamp_tz,
                                  'day'))
    )
    , month_date_series_and_transport_dates as (
    select mds.month_date,
    --     d.delivery_id as transport_id,
         d.charge,
         date_trunc('month', d.scheduled_date)::date as scheduled_month,
         date_trunc('month', d.completed_date)::date as completed_month
    from month_date_series mds
        left join ES_WAREHOUSE.public.deliveries d on mds.month_date = date_trunc('month', d.scheduled_date)::date or mds.month_date = date_trunc('month', d.completed_date)::date
        left join ES_WAREHOUSE.public.orders o on d.order_id = o.order_id
        left join ES_WAREHOUSE.public.markets m on o.market_id = m.market_id
    where m.company_id = {{ _user_attributes['company_id'] }}
    )
 --   , dummy_counts_for_summarization as (
    select month_date,
        case when month_date = scheduled_month then 1 else 0 end as scheduled,
        case when month_date = completed_month then 1 else 0 end as completed,
        case when month_date = scheduled_month then charge else 0 end as scheduled_delivery_charge
    from month_date_series_and_transport_dates
    ;;
  }


  dimension_group: month_date {
    type: time
    timeframes: [month]
    sql: ${TABLE}."MONTH_DATE";;
  }

  dimension: scheduled_delivery_charge {
    type: number
    sql: ${TABLE}."SCHEDULED_DELIVERY_CHARGE";;
  }

  dimension: scheduled {
    type: number
    sql: ${TABLE}."SCHEDULED";;
  }

  dimension: completed {
    type: number
    sql: ${TABLE}."COMPLETED";;
  }

  measure: scheduled_booked_charges {
    type: sum
    sql: ${scheduled_delivery_charge};;
    value_format_name: usd_0
  }

  measure: scheduled_transports {
    type: sum
    sql: ${scheduled};;
    value_format_name: decimal_0
  }

  measure: completed_transports {
    type: sum
    sql: ${completed};;
    value_format_name: decimal_0
  }

}
