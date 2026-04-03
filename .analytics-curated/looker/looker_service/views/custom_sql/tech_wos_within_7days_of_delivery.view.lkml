view: tech_wos_within_7days_of_delivery {
  derived_table:{
    sql:
with deliveries as (
        select d.asset_id,
               d.DELIVERY_ID,
               d.RENTAL_ID,
               d.delivery_status_id,
               ds.name,
               d.completed_date                                     as delivery_date,
               r.START_DATE                                         as rental_start,
               r.end_date                                           as rental_end
        from es_warehouse.public.deliveries                         as d
        inner join es_warehouse.public.delivery_statuses            as ds
            on d.delivery_status_id = ds.delivery_status_id
        left outer join es_warehouse.public.locations               as l
            on d.ORIGIN_LOCATION_ID = l.LOCATION_ID
        left outer join es_warehouse.public.rentals                 as r
            on r.RENTAL_ID = d.RENTAL_ID
        where d.asset_id is not null
          and l.COMPANY_ID = 1854
          and d.delivery_status_id = 3
    ), wos as (
        select wo.DATE_CREATED                                                  as wo_date,
               wo.WORK_ORDER_ID,
               wo.ASSET_ID,
               wo.WORK_ORDER_STATUS_NAME,
               wo.WORK_ORDER_TYPE_ID,
               wo.WORK_ORDER_TYPE_NAME,
               wo.ARCHIVED_DATE,
               wo.DESCRIPTION,
               wo.branch_id,
               LISTAGG(ct.name, ', ')                                           as tags
        from ES_WAREHOUSE.work_orders.work_orders                               as wo
        left outer join es_warehouse.work_orders.WORK_ORDER_COMPANY_TAGS        as tag
            on wo.WORK_ORDER_ID = tag.WORK_ORDER_ID
            and tag.deleted_on is null
        left outer join es_warehouse.work_orders.company_tags                   as ct
            on tag.COMPANY_TAG_ID = ct.COMPANY_TAG_ID
        left outer join es_warehouse.work_orders.WORK_ORDER_ORIGINATORS         as o
            on wo.work_order_id = o.WORK_ORDER_ID
        where wo.WORK_ORDER_TYPE_NAME <> 'Inspection'
          and o.originator_type_id <> 3 -- Maintenance Group Interval, system created
        -- and tag.company_tag_id not in (23,54, 985, 980, 888, 393, 486, 400, 401, 856, 1396, 1209)
        -- take out Equipment Transfer and anything to do with trackers
          and wo.work_order_id not in(select distinct work_order_id
                                      from "ES_WAREHOUSE"."WORK_ORDERS"."WORK_ORDER_COMPANY_TAGS"
                                      where company_tag_id in (23,54, 985, 980, 888, 393, 486, 400, 401, 856, 1396, 1209) and deleted_on is null)--excluding WOs tagged with customer damage or customer error
        group by wo.DATE_CREATED, wo.WORK_ORDER_ID, wo.ASSET_ID, wo.WORK_ORDER_STATUS_NAME, wo.WORK_ORDER_TYPE_ID, wo.WORK_ORDER_TYPE_NAME,
                 wo.ARCHIVED_DATE, wo.DESCRIPTION, wo.BRANCH_ID
    ), breakdown as (
        select d.asset_id,
               wos.DESCRIPTION,
               wos.TAGS,
               d.DELIVERY_ID,
               d.RENTAL_ID,
               wos.WORK_ORDER_ID,
               wos.work_order_type_id                                           as breakdown_type_id,
               wos.WORK_ORDER_TYPE_NAME,
               wos.WORK_ORDER_STATUS_NAME,
               d.DELIVERY_DATE,
               wos.WO_DATE,
               wos.BRANCH_ID,
               d.RENTAL_START,
               d.RENTAL_END
        from deliveries d
        inner join wos
            on d.ASSET_ID = wos.asset_id
           and wos.wo_date between d.delivery_date
           and iff(dateadd('days', 7, d.delivery_date) < d.rental_end, dateadd('days', 7, d.delivery_date), d.rental_end)
        inner join es_warehouse.PUBLIC.ASSETS_AGGREGATE aa
            on wos.ASSET_ID = aa.ASSET_ID
        where aa.COMPANY_ID = 1854
          and aa.ASSET_TYPE_ID = 1
          and aa.RENTAL_BRANCH_ID is not null
          and d.delivery_date < d.rental_end
          and wos.description not ilike '%Failed Inspection Items%INSP%'
    ), last_touched as (
        select wo.asset_id
             , max(wo.date_completed) last_touched
        from ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS                       as wo
        inner join breakdown b
            on wo.asset_id = b.asset_id
           and wo.date_completed < b.wo_date
        -- where wo.asset_id = 64002
        group by wo.asset_id
    ), last_wo as (
        select wo.asset_id
             , wo.branch_id
             , wo.work_order_type_id                                        as last_work_order_type_id
             , wo.work_order_type_name                                      as last_work_order_type_name
             , work_order_id                                                as last_work_order
             , date_completed                                               as last_touched
             , c.user_id                                                    as last_tech_id
             , u.first_name||' '||u.last_name last_tech_name
        from ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS wo
        inner join  ES_WAREHOUSE.PUBLIC.COMMAND_AUDIT c --may need to adjust this due to WOs opening/closing repeatedly, WO date_completed= CA update?
            on wo.work_order_id = c.parameters:work_order_id
           and to_date(wo.date_completed) = to_date(c.date_created)
        inner join ES_WAREHOUSE.PUBLIC.USERS u
            on c.user_id = u.user_id
        inner join ANALYTICS.PAYROLL.COMPANY_DIRECTORY cd
            on to_char(u.employee_id) = to_char(cd.employee_id)
        inner join last_touched lt
            on wo.date_completed = lt.last_touched
           and wo.asset_id = lt.asset_id
        where c.COMMAND = 'CloseWorkOrder'
    )
    select b.asset_id
         , tags breakdown_tags
         , delivery_id
         , rental_id
         , work_order_id breakdown_wo
         , breakdown_type_id
         , delivery_date
         , wo_date
         , rental_start
         , rental_end
         , lw.*
    from last_wo lw
    inner join breakdown b
        on lw.asset_id = b.asset_id
       and lw.last_touched < b.wo_date
 ;;

}
  dimension: selected_hierarchy {
    type: string
    sql:{% if market_region_xwalk.market_name._in_query %}
          ${last_tech_name}
        {% elsif  market_region_xwalk.district._in_query %}
          ${market_region_xwalk.market_name}
        {% else %}
          ${market_region_xwalk.district}
        {% endif %};;
  }

  dimension: last_tech_name  {
    type: string
    sql: ${TABLE}.last_tech_name ;;
  }

  dimension: last_tech_id {
    type:string
    sql: ${TABLE}.last_tech_id ;;
  }
  dimension: last_wo_id {
    type: string
    sql: ${TABLE}.last_work_order ;;
  }
  dimension: breakdown_wo_id {
    type: string
    sql: ${TABLE}.breakdown_wo ;;
  }
  dimension: breakdown_type_id {
    label: "Breakdown Work Order Type ID"
    type: number
    sql: ${TABLE}.breakdown_type_id ;;
  }
  dimension: last_work_order_type_id {
    label: "Last Work Order Type ID"
    type: number
    sql: ${TABLE}.last_work_order_type_id ;;
  }
  dimension: last_work_order_type_name {
    label: "Last Work Order Type Name"
    type: string
    sql: ${TABLE}.last_work_order_type_name ;;
  }
  dimension_group: breakdown {
    type: time
    timeframes: [date,week, month,year]
    sql: convert_timezone('America/Chicago',${TABLE}.wo_date);;
  }
  dimension: market_id {
    type: string
    sql: ${TABLE}.branch_id ;;
  }

  dimension: last_wo_id_with_link {
    type: string
    sql: ${last_wo_id} ;;
    html: <font color="blue "><u><a href="https://app.estrack.com/#/service/work-orders/{{ last_wo_id._value }}" target="_blank">{{ last_wo_id._value }}</a></font></u> ;;
  }

  measure: 7day_breakdowns {
  type: count_distinct
  sql: ${TABLE}.last_work_order ;;
  drill_fields: [
          breakdown_date
        , breakdown_work_order.work_order_id_with_link_to_work_order
        , breakdown_work_order.asset_id
        , breakdown_work_order.description
        ,last_wo_id_with_link]}

 }
