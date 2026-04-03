view: histroical_pm_compliance {
  derived_table: {
    sql:  with final as (
select
    oi.asset_id,
    oi.maintenance_group_interval_id,
    oi.maintenance_group_interval_name,
    oi.market_id,
    oi.date_of,
    oi.overdue_flag,
    oi.until_next_service_usage,
    case
        when contains(upper(oi.maintenance_group_interval_name),'BIT ') then '90 Day Bit'
        when contains(upper(oi.maintenance_group_interval_name),'CALIFORNIA CLEAN TRUCK CHECK') then 'California Clean Truck Check'
        when contains(upper(oi.maintenance_group_interval_name),'DOT ') then 'DOT'
        when contains(upper(oi.maintenance_group_interval_name),'90 DAY') then '90 Day'
        when contains(upper(oi.maintenance_group_interval_name),'CRANE') then 'Annual Crane'
        when contains(upper(oi.maintenance_group_interval_name),'IN-HOUSE') then 'Yearly In-House'
        when contains(upper(oi.maintenance_group_interval_name),'ANNUAL') OR contains(upper(oi.maintenance_group_interval_name),'YEARLY') then 'DOT'
        when contains(upper(oi.maintenance_group_interval_name),'50,000') then '50,000 Mile'
        else 'PM'
    end as service_type,
    case
        when oi.last_service_usage_value != lead(oi.last_service_usage_value) over (partition by oi.asset_id, oi.maintenance_group_interval_name order by oi.date_of) then 1
        when oi.last_service_time_value != lead(oi.last_service_time_value) over (partition by oi.asset_id, oi.maintenance_group_interval_name order by oi.date_of) then 1
        else 0
    end as completed_date_flag,
    case
        when oi.overdue_flag = 0 and lead(oi.overdue_flag) over (partition by oi.asset_id, oi.maintenance_group_interval_name order by oi.date_of) = 1 then 1
        when oi.overdue_flag = 0 and completed_date_flag = 1 then 1
        when oi.overdue_flag = 1 and dayofmonth(oi.date_of) = 1 then 1
        else 0
    end as due_date_flag,
    case
        when oi.overdue_flag = 0 and completed_date_flag = 1 then 'Before Due'
        when oi.overdue_flag = 0 and lead(oi.overdue_flag) over (partition by oi.asset_id, oi.maintenance_group_interval_name order by oi.date_of) = 1 then 'Due On'
        when oi.overdue_flag = 1 and dayofmonth(oi.date_of) = 1 then 'Overdue'
        else 'Other'
    end as due_date_flag_name,

    iff(due_date_flag_name in ('Before Due','Due On'),date_of,null) as due_date,
    iff(completed_date_flag = 1,date_of,null) as completed_date,
    oi.service_interval_type_name,
    iff(iea.asset_id is not null, true, false) as during_rental_assignment,
    r.rental_id,
    dc.company_id as rental_company_id,
    dc.company_name as rental_company_name
from analytics.service.overdue_inspections_snapshot  oi
left join ANALYTICS.ASSETS.INT_EQUIPMENT_ASSIGNMENTS iea
    on iea.asset_id = oi.asset_id
        and iea.date_start <= oi.date_of
        and iea.date_end >= oi.date_of
left join ES_WAREHOUSE.PUBLIC.RENTALS r
    on r.rental_id = iea.rental_id
left join ES_WAREHOUSE.PUBLIC.ORDERS o
    on o.order_id = r.rental_id
left join FLEET_OPTIMIZATION.GOLD.DIM_COMPANIES_FLEET_OPT dc
    on dc.company_id = o.company_id
)

select
    *,
    coalesce(lag(due_date) ignore nulls over (partition by asset_id, maintenance_group_interval_name order by date_of),min(date_of) over (partition by asset_id)) as last_due_date,
    coalesce(lag(completed_date) ignore nulls over (partition by asset_id, maintenance_group_interval_name order by date_of),min(date_of) over (partition by asset_id)) as last_completed_date,
    iff((completed_date_flag = 1),datediff(days,last_due_date,date_of),null) as days_overdue,
    iff((date_of = current_date),1,0) as current_date_flag,
    iff(current_date_flag = 1,datediff(days,last_due_date,date_of),null) as days_overdue_current
 from final  ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
    value_format: "0"
  }

  dimension: maintenance_group_interval_id {
    type: number
    sql: ${TABLE}."MAINTENANCE_GROUP_INTERVAL_ID" ;;
    value_format: "0"
  }

  dimension: asset_id_maintenance_group {
    type: string
    sql: concat(${asset_id},'-',${maintenance_group_interval_id}) ;;
  }

  dimension: maintenance_group_interval_name {
    type: string
    sql: ${TABLE}."MAINTENANCE_GROUP_INTERVAL_NAME" ;;
  }

  dimension: service_interval_type_name {
    type: string
    description: "Normal, Non-Transportation Assets Service Interval Name. Service Dashboard Configuration"
    sql: ${TABLE}.service_interval_type_name ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension_group: date_of {
    type: time
    timeframes: [raw,date,month,quarter,year]
    sql: ${TABLE}."DATE_OF" ;;
  }

  dimension: overdue_flag {
    type: number
    sql: ${TABLE}."OVERDUE_FLAG" ;;
  }

  dimension: miles_overdue {
    type: number
    sql: -${TABLE}."UNTIL_NEXT_SERVICE_USAGE" ;;
  }

  dimension: service_type {
    type: string
    sql: ${TABLE}."SERVICE_TYPE" ;;
  }

  dimension: completed_date_flag {
    type: number
    sql: ${TABLE}."COMPLETED_DATE_FLAG" ;;
  }

  dimension: due_date_flag {
    type: number
    sql: ${TABLE}."DUE_DATE_FLAG" ;;
  }

  dimension: due_date_flag_name {
    type: string
    sql: ${TABLE}."DUE_DATE_FLAG_NAME" ;;
  }

  dimension_group: due_date {
    type: time
    timeframes: [raw,date,month,quarter,year]
    sql: ${TABLE}."DUE_DATE" ;;
  }

  dimension_group: completed_date {
    type: time
    timeframes: [raw,date,month,quarter,year]
    sql: ${TABLE}."COMPLETED_DATE" ;;
  }

  dimension: current_date_flag {
    type: number
    sql: ${TABLE}."CURRENT_DATE_FLAG" ;;
  }

  dimension_group: last_due_date {
    type: time
    timeframes: [raw,date,month,quarter,year]
    sql: ${TABLE}."LAST_DUE_DATE" ;;
  }

  dimension_group: last_completed_date {
    type: time
    timeframes: [raw,date,month,quarter,year]
    sql: ${TABLE}."LAST_COMPLETED_DATE" ;;
  }

  dimension: days_overdue {
    type: number
    sql: ${TABLE}."DAYS_OVERDUE" ;;
  }

  dimension: days_overdue_current {
    type: number
    sql: ${TABLE}."DAYS_OVERDUE_CURRENT" ;;
  }

  measure: count {
    type: count_distinct
    filters: [work_orders.work_order_status_id: "1",work_orders.archived_date: "NULL"]
    sql: ${asset_id_maintenance_group} ;;
    drill_fields: [asset_id,users.driver,market_region_xwalk.market_name,maintenance_group_interval_name,last_due_date_date,last_completed_date_date,days_overdue_current,work_orders.work_order_id_with_link_to_work_order]
  }

  measure: count_due {
    type: sum
    sql: ${due_date_flag} ;;
    drill_fields: [asset_id,market_region_xwalk.market_name,maintenance_group_interval_name,last_due_date_date,last_completed_date_date]
  }

  measure: count_overdue {
    type: sum
    filters: [due_date_flag_name: "Due On, Overdue"]
    sql: ${due_date_flag} ;;
  }

  measure: count_completed {
    type: sum
    sql: ${completed_date_flag} ;;
  }

  measure: count_completed_overdue_days {
    type: sum
    filters: [overdue_flag: "1",completed_date_flag: "1"]
    sql: ${completed_date_flag} ;;
    drill_fields: [asset_id,user.full_name,market_region_xwalk.market_name,maintenance_group_interval_name,last_due_date_date,last_completed_date_date,days_overdue]
  }

  measure: count_completed_overdue_miles {
    type: sum
    filters: [overdue_flag: "1",completed_date_flag: "1"]
    sql: ${completed_date_flag} ;;
    drill_fields: [asset_id,user.driver,market_region_xwalk.market_name,maintenance_group_interval_name,last_due_date_date,last_completed_date_date,miles_overdue]
  }

  measure: count_became_due {
    type: sum
    filters: [due_date_flag_name: "Due On, Before Due"]
    sql: ${due_date_flag} ;;
  }

  measure: percent_overdue_days {
    label: "DOT Inspection Compliance"
    type: number
    value_format: "0.00%"
    sql: 1-(${count_completed_overdue_days} / iff(${count_due}=0,1,${count_due})) ;;
    drill_fields: [count_completed_overdue_days,count_due]
  }

  measure: percent_overdue_days_ansi {
    label: "ANSI Inspection Compliance"
    type: number
    value_format: "0.00%"
    sql: 1-(${count_completed_overdue_days} / iff(${count_due}=0,1,${count_due})) ;;
    drill_fields: [count_completed_overdue_days,count_due]
  }

  measure: percent_overdue_days_annual {
    label: "Annual Inspection Compliance"
    type: number
    value_format: "0.00%"
    sql: 1-(${count_completed_overdue_days} / iff(${count_due}=0,1,${count_due})) ;;
    drill_fields: [count_completed_overdue_days,count_due]
  }

  measure: percent_overdue_miles {
    label: "PM Compliance"
    type: number
    value_format: "0.00%"
    sql: 1-(${count_completed_overdue_miles} / iff(${count_due}=0,1,${count_due})) ;;
    drill_fields: [count_completed_overdue_miles,count_due]
  }

  measure: percent_overdue_2 {
    type: number
    value_format: "0.00%"
    sql: ${count_overdue} / ${count_due} ;;
  }

  measure: average_days_overdue {
    type: average
    sql: ${days_overdue} ;;
    filters: [days_overdue: "NOT NULL"]
    drill_fields: [asset_id,market_region_xwalk.market_name,maintenance_group_interval_name,last_due_date_date,last_completed_date_date,miles_overdue,work_orders.work_order_id_with_link_to_work_order]
  }

  measure: average_days_overdue_current {
    type: average
    sql: ${days_overdue_current} ;;
    filters: [overdue_flag: "1"]
    drill_fields: [asset_id,market_region_xwalk.market_name,maintenance_group_interval_name,last_due_date_date,last_completed_date_date,days_overdue_current,miles_overdue,work_orders.work_order_id_with_link_to_work_order]
  }

  dimension: during_rental_assignment {
    type: yesno
    sql: ${TABLE}.during_rental_assignment ;;
  }

  dimension: rental_company_name {
    type: string
    sql: ${TABLE}.rental_company_name ;;
  }
}
