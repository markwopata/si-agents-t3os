view: completed_pm_work_orders {
  derived_table: {
    sql: select
        a.asset_id,
        count(distinct wo.work_order_id) as work_order_id,
        case
            when contains(upper(wo.description),'BIT ') then '90 Day Bit'
            when contains(upper(wo.description),'DOT ') then 'DOT'
            when contains(upper(wo.description),'90 DAY') then '90 Day'
            when contains(upper(wo.description),'CRANE') then 'Annual Crane'
            when contains(upper(wo.description),'IN-HOUSE') then 'Yearly In-House'
            when contains(upper(wo.description),'ANNUAL') OR contains(upper(wo.description),'YEARLY') then 'DOT'
            when contains(upper(wo.description),'50,000') then '50,000 Mile'
            when wo.description is not null then 'PM'
            else null
        end as transportation_service_interval_type
    from es_warehouse.public.assets a
    left join es_warehouse.work_orders.work_orders wo
        on wo.asset_id = a.asset_id
    join es_warehouse.work_orders.work_order_originators woo
        on woo.work_order_id = wo.work_order_id
    where wo.work_order_status_id in (3,4)
    and woo.originator_type_id = 3
    and transportation_service_interval_type = 'PM'
    group by a.asset_id,transportation_service_interval_type;;
  }

  dimension: asset_id {
    type: string
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: completed_pm_count {
    type: number
    sql: coalesce(${TABLE}."WORK_ORDER_ID",0) ;;
  }

  dimension: transportation_service_interval_type {
    type: string
    sql: ${TABLE}."TRANSPORTATION_SERVICE_INTERVAL_TYPE" ;;
  }

  measure: miles_per_pm {
    type: number
    sql: ${v_assets.asset_odometer}/iff(${completed_pm_count}=0,1,${completed_pm_count}) ;;
  }
}
