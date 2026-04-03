view: 7day_breakdowns {
  derived_table:{
    sql:
with deliveries as (
    select d.asset_id,
           d.DELIVERY_ID,
           d.RENTAL_ID,
           d.delivery_status_id,
           d.delivery_type_id,
           dt.name                                                          as delivery_type,
           ds.name,
           d.completed_date                                                 as delivery_date,
           r.START_DATE                                                     as rental_start,
           r.end_date                                                       as rental_end,
           ea.END_DATE                                                      as equipment_assignment_end
    from es_warehouse.public.deliveries                                     as d
    left join es_warehouse.public.equipment_assignments                     as ea on d.asset_id = ea.ASSET_ID AND d.DELIVERY_ID = ea.DROP_OFF_DELIVERY_ID
    inner join es_warehouse.public.delivery_statuses                        as ds on d.delivery_status_id = ds.delivery_status_id
    left join es_warehouse.public.delivery_types                            as dt on dt.delivery_type_id = d.delivery_type_id
    left outer join es_warehouse.public.locations                           as l on d.ORIGIN_LOCATION_ID = l.LOCATION_ID
    left outer join es_warehouse.public.rentals                             as r on r.RENTAL_ID = d.RENTAL_ID
    left join es_warehouse.public.rental_statuses                           as rs on rs.rental_status_id = r.rental_status_id
    where d.asset_id is not null
      and l.COMPANY_ID = 1854
      and d.delivery_status_id = 3
      and d.DELIVERY_TYPE_ID in (1,3)
), wos as (
    select wo.DATE_CREATED                                                  as wo_date,
           wo.date_completed,
           wo.WORK_ORDER_ID,
           wo.ASSET_ID,
           wo.WORK_ORDER_STATUS_NAME,
           wo.WORK_ORDER_TYPE_ID,
           wo.WORK_ORDER_TYPE_NAME,
           wo.ARCHIVED_DATE,
           wo.DESCRIPTION,
           wo.branch_id,
           LISTAGG(ct.name, ', ')                                           as tags,
    from ES_WAREHOUSE.work_orders.work_orders                               as wo
    left outer join es_warehouse.work_orders.WORK_ORDER_COMPANY_TAGS        as tag
        on wo.WORK_ORDER_ID = tag.WORK_ORDER_ID
    left outer join es_warehouse.work_orders.company_tags                   as ct
        on tag.COMPANY_TAG_ID = ct.COMPANY_TAG_ID
    left outer join es_warehouse.work_orders.WORK_ORDER_ORIGINATORS         as o
        on wo.work_order_id = o.WORK_ORDER_ID
    where wo.WORK_ORDER_TYPE_NAME <> 'Inspection' and
          o.originator_type_id <> 3 -- Maintenance Group Interval, system created
    -- and tag.company_tag_id not in (23,54, 985, 980, 888, 393, 486, 400, 401, 856, 1396, 1209)
    -- take out Equipment Transfer and anything to do with trackers
      and wo.work_order_id not in(select distinct work_order_id
                                  from "ES_WAREHOUSE"."WORK_ORDERS"."WORK_ORDER_COMPANY_TAGS"
                                  where company_tag_id in (23,54, 985, 980, 888, 393, 486, 400, 401, 856, 1396, 1209))--excluding WOs tagged with customer damage or customer error
    group by wo.DATE_CREATED, wo.WORK_ORDER_ID, wo.date_completed, wo.ASSET_ID, wo.WORK_ORDER_STATUS_NAME, wo.WORK_ORDER_TYPE_ID, wo.WORK_ORDER_TYPE_NAME,
             wo.ARCHIVED_DATE, wo.DESCRIPTION, wo.BRANCH_ID
    order by wo.DATE_CREATED
), breakdown as (
    select d.asset_id,
           wos.WORK_ORDER_ID,
           wos.work_order_type_id,
           wos.WORK_ORDER_TYPE_NAME,
           wos.WORK_ORDER_STATUS_NAME,
           wos.DESCRIPTION,
           wos.BRANCH_ID,
           wos.TAGS,
           d.RENTAL_ID,
           d.DELIVERY_ID,
           d.delivery_type,
           wos.WO_DATE,
           wos.date_completed,
           d.delivery_date,
           d.RENTAL_START,
           d.RENTAL_END,
           d.equipment_assignment_end
    from deliveries d
    inner join wos
        on d.ASSET_ID = wos.asset_id
       and wos.wo_date between d.delivery_date
       and iff(dateadd('days', 7, d.delivery_date) < least(d.equipment_assignment_end,d.rental_end), dateadd('days', 7, d.delivery_date), least(d.equipment_assignment_end,d.rental_end))
    inner join es_warehouse.PUBLIC.ASSETS_AGGREGATE aa
        on wos.ASSET_ID = aa.ASSET_ID
    where aa.COMPANY_ID = 1854
      and aa.ASSET_TYPE_ID = 1
      and aa.RENTAL_BRANCH_ID is not null
      and d.delivery_date < least(d.equipment_assignment_end,d.rental_end)
      and wos.description not ilike '%Failed Inspection Items%INSP%'
--           and calculation is not null
    order by d.delivery_date, d.rental_start, d.rental_end, wos.wo_date, wos.date_completed, equipment_assignment_end
), last_work_order as (
    select wo.DATE_CREATED,
           wo.date_completed,
           wo.WORK_ORDER_ID,
           wo.description,
           wo.ASSET_ID,
           lag(wo.WORK_ORDER_ID) over (partition by wo.asset_id order by wo.DATE_COMPLETED asc)     as prev_work_order_id,
           lag(wo.DATE_COMPLETED) over (partition by wo.asset_id order by wo.DATE_COMPLETED asc)    as prev_work_completed_date
    from ES_WAREHOUSE.work_orders.work_orders                                                       as wo
    left join breakdown as b on wo.WORK_ORDER_ID = b.WORK_ORDER_ID
    where wo.archived_date is null
    qualify prev_work_completed_date is not null
    order by wo.WORK_ORDER_ID
), prev_user_details as (
    select lw.prev_work_order_id,
           u.user_id                                                                            as last_tech_id,
           cd.FIRST_NAME||' '||cd.LAST_NAME                                                     as last_tech_name
    from last_work_order as lw
    join ES_WAREHOUSE.TIME_TRACKING.time_entries as te on lw.prev_work_order_id = te.work_order_id
    join ES_WAREHOUSE.PUBLIC.USERS as u on te.user_id = u.user_id
    inner join ANALYTICS.PAYROLL.COMPANY_DIRECTORY as cd on to_char(u.employee_id) = to_char(cd.employee_id)
    group by lw.prev_work_order_id, u.user_id, last_tech_name
)
--, temp as (
select concat(b.rental_id,'-',b.work_order_id,'-',lw.work_order_id,'-',pd.last_tech_id) as pk --rental_id needs to be here because of work order 2308829 and many others
     , b.asset_id
     , b.rental_id
     , b.work_order_id              as breakdown_wo
     , b.WORK_ORDER_TYPE_ID         as breakdown_type_id
     , b.WORK_ORDER_TYPE_NAME       as breakdown_type_name
     , b.description                as breakdown_description
     , b.tags                       as breakdown_tags
     , b.branch_id                  as breakdown_branch_id
     , b.delivery_id
     , b.wo_date                    as breakdown_date
     , b.delivery_date
     , b.rental_start
     , b.equipment_assignment_end
     , b.rental_end
     , lw.prev_work_order_id
     , wo.DATE_CREATED              as prev_wo_created
     , lw.DATE_CREATED              as prev_wo_completed
     , wo.DESCRIPTION               as prev_description
     , wo.WORK_ORDER_TYPE_ID        as prev_wo_type_id
     , wo.WORK_ORDER_TYPE_NAME      as prev_wo_type_name
     , pd.last_tech_id              as prev_tech_id
     , pd.last_tech_name            as prev_tech_name
     , bt.name                      as prev_wo_billing_type_name
     , case
         when woo.ORIGINATOR_TYPE_ID = 3 then 'MGI'
         when wo.WORK_ORDER_TYPE_ID = 1 then 'General'
         when wo.WORK_ORDER_TYPE_ID = 2 then 'Inspection'
         else 'Unknown' end                                     as prev_wo_type_origin
from last_work_order lw
inner join breakdown b
    on lw.asset_id = b.asset_id
   and lw.work_order_id = b.work_order_id
left join prev_user_details pd on lw.prev_work_order_id = pd.prev_work_order_id
left join ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS as wo on lw.prev_work_order_id = wo.WORK_ORDER_ID
left join ES_WAREHOUSE.WORK_ORDERS.WORK_ORDER_ORIGINATORS as woo on wo.WORK_ORDER_ID = woo.WORK_ORDER_ID
left join ES_WAREHOUSE.WORK_ORDERS.BILLING_TYPES as bt on wo.billing_type_id = bt.billing_type_id
where lw.prev_work_order_id is not null
--       and pk is null  --there were 772 rows with either a null prev_date_completed or null prev_tech_id
order by b.asset_id, b.rental_id, b.delivery_date, b.wo_date, b.rental_start, b.rental_end
     ;;
  }
  dimension: pk {
    type: number
    value_format_name: id
    primary_key: yes
    sql: ${TABLE}.pk ;;
  }
  dimension: selected_hierarchy {
    type: string
    sql:
    {% if market_region_xwalk.market_name._in_query %}
      ${prev_tech_name}
    {% elsif market_region_xwalk.district._in_query %}
      ${market_region_xwalk.market_name}
    {% else %}
      ${market_region_xwalk.district}
    {% endif %} ;;
  }
  dimension: asset_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.asset_id ;;
  }

  dimension: prev_tech_name  {
    type: string
    sql: ${TABLE}.prev_tech_name ;;
  }
  dimension: prev_tech_id {
    type: string
    sql: ${TABLE}.prev_tech_id ;;
    primary_key: no
  }
  dimension: prev_wo_type_origin {
    type: string
    sql: ${TABLE}.prev_wo_type_origin ;;
  }
  dimension: prev_wo_type_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.prev_wo_type_id ;;
  }
  dimension: prev_wo_type_name {
    type: string
    sql: ${TABLE}.prev_wo_type_name ;;
  }
  dimension: prev_work_order_id {
    label: "Last Work Order ID"
    type: string
    sql: ${TABLE}.prev_work_order_id ;;
  }
  dimension: prev_wo_billing_type_name {
    label: "Previous Work Order Billing Type Name"
    type: string
    sql: ${TABLE}.prev_wo_billing_type_name ;;
  }
  dimension_group: prev_created {
    label: "Previous WO Created"
    type: time
    timeframes: [raw,date,week,month,year]
    sql: CONVERT_TIMEZONE('America/Chicago', ${TABLE}.prev_wo_created) ;;
  }
  dimension_group: prev_completed {
    label: "Previous WO Completed"
    type: time
    timeframes: [raw, date, week, month, year]
    sql: CONVERT_TIMEZONE('America/Chicago', ${TABLE}.prev_wo_completed) ;;
  }

  dimension: prev_wo_description {
    label: "Previous WO Description"
    type: string
    sql: ${TABLE}.prev_description ;;
  }

  dimension_group: equipment_assignment_end {
    description: "Date asset was removed from rental"
    type: time
    timeframes: [raw, date, week, month, year]
    sql: CONVERT_TIMEZONE('America/Chicago', ${TABLE}.equipment_assignment_end) ;;
  }

  dimension: breakdown_wo_id {
    label: "Breakdown Work Order ID"
    type: string
    sql: ${TABLE}.breakdown_wo ;;
  }

  dimension: breakdown_description {
    label: "Breakdown Description"
    type: string
    sql: ${TABLE}.breakdown_description ;;
  }
  dimension: breakdown_type_id {
    label: "Breakdown Work Order Type ID"
    type: number
    sql: ${TABLE}.breakdown_type_id ;;
  }
  dimension: breakdown_branch_id {
    type: number
    sql: ${TABLE}.breakdown_branch_id ;;
  }

  dimension_group: breakdown {
    type: time
    timeframes: [raw, date, week, month, year]
    sql: CONVERT_TIMEZONE('America/Chicago', ${TABLE}.breakdown_date) ;;
  }

  dimension_group: delivery {
    label: "Delivery"
    type: time
    timeframes: [raw, date, week, month, year]
    sql: CONVERT_TIMEZONE('America/Chicago', ${TABLE}.delivery_date) ;;
  }

  dimension_group: rental_start {
    label: "Rental Start"
    type: time
    timeframes: [raw, date, week, month, year]
    sql: CONVERT_TIMEZONE('America/Chicago', ${TABLE}.rental_start) ;;
  }

  dimension_group: rental_end {
    label: "Rental End"
    type: time
    timeframes: [raw, date, week, month, year]
    sql: CONVERT_TIMEZONE('America/Chicago', ${TABLE}.rental_end) ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}.branch_id ;;
  }

  # Links
  dimension: prev_work_order_id_with_link {
    type: string
    sql: ${prev_work_order_id} ;;
    html: <font color='blue'><u><a href='https://app.estrack.com/#/service/work-orders/{{ prev_work_order_id._value }}' target='_blank'>{{ prev_work_order_id._value }}</a></u></font> ;;
  }

  dimension: breakdown_wo_id_with_link {
    label: "Breakdown WO Link"
    type: string
    sql: ${breakdown_wo_id} ;;
    html: <font color='blue'><u><a href='https://app.estrack.com/#/service/work-orders/{{ breakdown_wo_id._value }}' target='_blank'>{{ breakdown_wo_id._value }}</a></u></font> ;;
  }

  dimension: asset_id_with_link {
    label: "Asset ID with Link to T3 Asset Details"
    type: string
    sql: ${asset_id} ;;
    html: <font color='blue'><u><a href='https://app.estrack.com/#/assets/all/asset/{{ asset_id._value }}/service/overview' target='_blank'>{{ asset_id._value }}</a></u></font> ;;
  }

  # Helper durations
  dimension: hours_from_delivery_to_breakdown {
    type: number
    value_format: "#,##0"
    sql: DATEDIFF('hour', ${delivery_raw}, ${breakdown_raw}) ;;
  }

  dimension: days_from_delivery_to_breakdown {
    type: number
    value_format: "#,##0.0"
    sql: DATEDIFF('day', ${delivery_raw}, ${breakdown_raw}) ;;
  }
  dimension: prev_wo_techs_list {
    type: string
    sql: LISTAGG(${prev_tech_name},', ') WITHIN GROUP (ORDER BY ${prev_work_order_id}) ;;
    order_by_field: prev_work_order_id
  }

  measure: 7day_breakdowns {
    description: "Count of total breakdowns.  Drill down data may be expanded if multiple techs worked on the previous work order."
    type: count_distinct
    sql: ${breakdown_wo_id} ;;
    drill_fields: [
                    asset_id_with_link,
                    breakdown_wo_id_with_link,
                    breakdown_date,
                    breakdown_description,
                    delivery_date,
                    rental_start_date,
                    rental_end_date,
                    equipment_assignment_end_date,
                    days_from_delivery_to_breakdown,
                    prev_work_order_id_with_link,
                    prev_wo_type_name,
                    prev_wo_description,
                    prev_wo_billing_type_name,
                    prev_created_date,
                    prev_completed_date
                  ]
  }

  measure: count {
    type: number
  }

  measure: breakdowns {
    label: "Breakdowns (Rows)"
    type: count
    drill_fields: [breakdown_wo_id, prev_work_order_id]
  }

  measure: assets_affected {
    label: "Assets Affected"
    type: count_distinct
    sql: ${TABLE}.asset_id ;;
  }

  measure: technicians_involved {
    label: "Technicians Involved"
    type: count_distinct
    sql: ${TABLE}.prev_tech_id ;;
  }

  measure: latest_breakdown_date {
    label: "Latest Breakdown Date"
    type: max
    sql: ${breakdown_raw} ;;
    value_format: "yyyy-MM-dd HH:mm"
  }

  measure: avg_hours_from_delivery_to_breakdown {
    label: "Avg Hours from Delivery to Breakdown"
    type: average
    sql: ${hours_from_delivery_to_breakdown} ;;
    value_format: "#,##0.0"
  }
}
