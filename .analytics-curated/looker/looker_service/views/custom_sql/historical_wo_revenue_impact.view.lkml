view: historical_wo_revenue_impact {
  derived_table: {
    sql:
with generated_dates as (
    select
        dateadd(day,'-' || row_number() over (order by null),dateadd(day, '+1', current_date()))    as generated_date
    from table (generator(rowcount => 366))
), tag_dates as (
    select ca.PARAMETERS:work_order_id                                                              as work_order_id,
           ca.PARAMETERS:tag_name                                                                   as tag_name,
           ca.COMMAND,
           ca.PARAMETERS,
--         Tag Applied Date (TAD), Tag Removed Date (TRD), wo.date_completed (LCD) all used to get to the number of
--         days a tag was applied.  If it wasn't removed before closing the WO, then the date closed is the last day.
--         If neither has happened yet, then we calculate to today's date.
           ca.DATE_CREATED                                                                          as tad,
           lead(ca.DATE_CREATED) over (partition by ca.parameters:work_order_id,tag_name
                                    order by ca.DATE_CREATED asc)                                   as trd,
  wo.date_completed,
           least(coalesce(trd,wo.date_completed),coalesce(wo.date_completed,current_date))          as calculated_last_tag_date,
           datediff(days, tad,calculated_last_tag_date)                                             as tagged_days
    from ES_WAREHOUSE.PUBLIC.COMMAND_AUDIT                                                          as ca
        join ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS                                                   as wo
            on ca.PARAMETERS:work_order_id = wo.work_order_id
    where ca.COMMAND in ('DisassociateWorkOrderTag',
                         'AssociateCompanyTag',
                         'UpdateTag',
                         'CreateAndAssociateCompanyTag') and
          ca.PARAMETERS:tag_name ilike '%Parts Needed%'
  qualify tagged_days>7
)
select gd.generated_date, --this is the field that would now be the month to plot
       wo.BRANCH_ID,
       wo.WORK_ORDER_ID,
       count(*) over (partition by wo.WORK_ORDER_ID,td.tagged_days,gd.generated_date)           as num_of_occurances, --this is still helpful since they could have two tags at once
       td.tag_name,
       td.tagged_days, --could be informative for drills but technically not needed now that there is a day for every work order
       wo.ASSET_ID,
       wo.DATE_CREATED::date                                                                    as wo_date_created,
       rr.CLASS_REVENUE_PER_RENTAL_DAY --this would now be the revenue impact that would be a summed measure in looker
from generated_dates                                                                            as gd
    join ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS                                                   as wo
        on gd.generated_date between wo.date_created and coalesce(wo.date_completed, current_date)
    join tag_dates                                                                              as td
        on wo.WORK_ORDER_ID = td.work_order_id and
           gd.generated_date between td.tad and td.calculated_last_tag_date
    join ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE                                                   as aa
        on wo.ASSET_ID = aa.ASSET_ID
    join FLEET_OPTIMIZATION.GOLD.V_RENTAL_REVENUE_BY_CLASS                                      as rr
        on aa.EQUIPMENT_CLASS_ID = rr.EQUIPMENT_CLASS_ID and
           gd.generated_date between rr.START_DATE and rr.END_DATE
where wo.archived_date is null
    and command != 'DisassociateWorkOrderTag'
--     below is a list of known work orders with multiple tags for the same period.  Not all inclusive
--     and wo.work_order_id in (4975901,4065128,4088807,5063659,4435015,4516293,3174722,3179912,3844728,4441280,3859329,4250506)
--     and wo.work_order_id = 3742843
--     and branch_id = 109984 -- Rapid City, SD
;;
  }
  # dimension: pkey {
  #   primary_key: yes
  #   hidden: yes
  #   sql: concat(${market_id},${asset_id},${work_order_id}) ;;
  # }
  dimension: market_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."BRANCH_ID" ;;
  }
  dimension: work_order_id {
    primary_key: yes
    type: number
    value_format_name: id
    sql: ${TABLE}."WORK_ORDER_ID" ;;
  }
  dimension: num_of_occurances {
    type: number
    sql: ${TABLE}."NUM_OF_OCCURANCES" ;;
  }
  dimension: asset_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."ASSET_ID" ;;
  }
  dimension_group: generated_date {
    type: time
    timeframes: [raw,time,date,week,month,quarter,year]
    sql: ${TABLE}."GENERATED_DATE" ;;
  }
  dimension: tag_name {
    type: string
    sql: ${TABLE}."TAG_NAME" ;;
  }
  dimension: tagged_days {
    type: number
    sql: ${TABLE}."TAGGED_DAYS" ;;
  }
  dimension: total_assets_in_class {
    type: number
    sql: ${TABLE}."TOTAL_ASSETS_IN_CLASS" ;;
  }
  dimension: total_class_revenue {
    type: number
    sql: ${TABLE}."TOTAL_CLASS_REVENUE" ;;
  }
  dimension: class_revenue_per_rental_day {
    type: number
    value_format_name: usd
    sql: ${TABLE}."CLASS_REVENUE_PER_RENTAL_DAY" ;;
  }
  dimension: revenue_impact {
    type: number
    value_format_name: usd
    sql: ${class_revenue_per_rental_day} * ${tagged_days} ;;
  }
  measure: total_tagged_days {
    type: sum
    sql: ${tagged_days} ;;
  }
  measure: total_num_of_occurances {
    label: "Number of Work Orders with duplicated tags"
    hidden: yes
    type: sum
    sql: ${num_of_occurances} ;;
    drill_fields: [tagged_work_order_details*]
    filters: [num_of_occurances: ">1"]
  }
  measure: total_revenue_impact {
    type: sum
    value_format_name: usd
    sql: ${class_revenue_per_rental_day} ;;
    drill_fields:[_detail_region*]
  }
  measure: total_revenue_impact_hidden {
    label: "Total Revenue Impact"
    hidden: yes
    type: sum
    value_format_name: usd
    sql: ${class_revenue_per_rental_day} ;;
    drill_fields:[_detail_market*]
  }
  measure: count_work_orders {
    type: count_distinct
    sql: ${work_order_id} ;;
  }
  set: _detail_region {
    fields: [
            market_region_xwalk.region_name,
            count_work_orders,
            total_tagged_days,
            total_num_of_occurances,
            total_revenue_impact_hidden
            ]
  }
  set: _detail_market {
    fields: [
            market_region_xwalk.market_name,
            work_orders.work_order_id_with_link_to_work_order,
            work_orders.work_order_status_name,
            assets_aggregate.class,
            tag_name,
            tagged_days,
            class_revenue_per_rental_day,
            revenue_impact
            ]
  }
  set: tagged_work_order_details {
    fields: [
            market_region_xwalk.market_name,
            work_orders.work_order_id_with_link_to_work_order,
            work_orders.work_order_status_name,
            num_of_occurances,
            tag_name,
            tagged_days,
            ]
  }
}
