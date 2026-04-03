view: work_orders_during_rentals {
  derived_table: {
    sql:
select r.rental_id
    , iea.asset_id
    , wo.work_order_id
    , wo.date_created
    , least(coalesce(wo.date_completed, '9999-12-31'), iea.date_end) completed_or_swap_date
    , datediff(hour, wo.date_created, least(coalesce(wo.date_completed, '9999-12-31'), iea.date_end)) as hours_to_complete_or_swap
from ES_WAREHOUSE.PUBLIC.RENTALS r
join analytics.assets.int_equipment_assignments iea
    using(iea.rental_id)
join ES_WAREHOUSE.PUBLIC.ORDERS o
    using(o.order_id)
join (
        select wo.work_order_id, wo.asset_id, wo.date_created, wo.date_completed
        from ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS wo
      --  left join ES_WAREHOUSE.WORK_ORDERS.WORK_ORDER_ORIGINATORS woo
      --      on woo.work_order_id = wo.work_order_id
        -- where wo.work_order_type_name ilike 'General'
        --    and woo.originator_type_id <> 3
        ) wo
    on wo.asset_id = iea.asset_id
        and wo.date_created >= iea.date_start
        and wo.date_created <= iea.date_end
where (wo.date_completed is not null or iea.date_end::DATE < '9999-12-31')
    -- and hours_to_complete_or_swap >= 0 --Not sure how these exist | https://app.estrack.com/#/service/work-orders/5728082/updates
    ;;
  }

  dimension: rental_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.rental_id ;;
  }
  dimension: asset_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.asset_id ;;
  }
  dimension: work_order_id {
    type: number
    value_format_name: id
    primary_key: yes
    sql: ${TABLE}.work_order_id ;;
  }
  dimension_group: work_order_created {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    sql: ${TABLE}.date_created ;;
  }
  dimension_group: completed_or_swap {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    sql: ${TABLE}.completed_or_swap_date ;;
  }
  dimension: hours_to_complete_or_swap {
    type: number
    sql: ${TABLE}.hours_to_complete_or_swap ;;
  }
  measure: avg_hours_to_complete_or_swap {
    type: average
    value_format_name: decimal_1
    sql: ${hours_to_complete_or_swap} ;;
  }
  measure: count {
    type: count
    drill_fields: [
      dim_companies_fleet_opt.company_name
      , rental_id
      , work_order_id
      , asset_id
      , work_order_created_date
      , completed_or_swap_date
      , hours_to_complete_or_swap
    ]
  }
  dimension: time_to_complete_distribution_buckets {
    type: string
    sql:
    case
      when ${hours_to_complete_or_swap} < 0 then 'Impossible'
      when ${hours_to_complete_or_swap} >= 0 and ${hours_to_complete_or_swap} <= 1 then 'Within 1 Hour'
      when ${hours_to_complete_or_swap} = 2 then 'Within 2 Hours'
      when ${hours_to_complete_or_swap} = 3 then 'Within 3 Hours'
      when ${hours_to_complete_or_swap} = 4 then 'Within 4 Hours'
      when ${hours_to_complete_or_swap} > 4 and ${hours_to_complete_or_swap} <= 8 then '5 - 8 Hours'
      when ${hours_to_complete_or_swap} > 8 and ${hours_to_complete_or_swap} <= 12 then '9 - 12 Hours'
      when ${hours_to_complete_or_swap} > 12 and ${hours_to_complete_or_swap} <= 16 then '13 - 16 Hours'
      when ${hours_to_complete_or_swap} > 16 and ${hours_to_complete_or_swap} <= 20 then '16 - 20 Hours'
      when ${hours_to_complete_or_swap} > 21 and ${hours_to_complete_or_swap} <= 26 then '21 - 26 Hours'
      when ${hours_to_complete_or_swap} > 26 and ${hours_to_complete_or_swap} <= 48 then '27 - 48 Hours'
      when ${hours_to_complete_or_swap} > 49 and ${hours_to_complete_or_swap} <= 72 then '49 - 72 Hours'
      else '> 72 Hours' end;;
  }
}
