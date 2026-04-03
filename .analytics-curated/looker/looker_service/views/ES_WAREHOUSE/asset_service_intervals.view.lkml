view: asset_service_intervals {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."ASSET_SERVICE_INTERVALS"
    ;;


  dimension: pkey {
    primary_key: yes
    type: string
    sql: CONCAT(${asset_id}, ${maintenance_group_interval_id}) ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
    html: <font color="blue "><u><a href="https://app.estrack.com/#/assets/all/asset/{{ asset_id }}/service/work-orders" target="_blank">{{rendered_value}}</a></font></u> ;;
  }

  dimension: service_interval_id {
    type: number
    sql: ${TABLE}."SERVICE_INTERVAL_ID" ;;
  }

  dimension: maintenance_group_interval_id {
    type: number
    sql: ${TABLE}."MAINTENANCE_GROUP_INTERVAL_ID" ;;
  }

  dimension: maintenance_group_id {
    type: number
    sql: ${TABLE}."MAINTENANCE_GROUP_ID" ;;
  }

  dimension: usage_interval_id {
    type: number
    sql: ${TABLE}."USAGE_INTERVAL_ID" ;;
  }

  dimension: time_interval_id {
    type: number
    sql: ${TABLE}."TIME_INTERVAL_ID" ;;
  }

  dimension: hours {
    type: number
    sql: ${TABLE}."HOURS" ;;
  }

  dimension: odometer {
    type: number
    sql: ${TABLE}."ODOMETER" ;;
  }

  dimension_group: date_created {
    type: time
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension: service_interval_name {
    type: string
    sql: ${TABLE}."SERVICE_INTERVAL_NAME" ;;
  }

  dimension: time_unit_id {
    type: number
    sql: ${TABLE}."TIME_UNIT_ID" ;;
  }

  dimension: time_value {
    type: number
    sql: ${TABLE}."TIME_VALUE" ;;
  }

  dimension: usage_unit_id {
    type: number
    sql: ${TABLE}."USAGE_UNIT_ID" ;;
  }

  dimension: usage_value {
    type: number
    sql: ${TABLE}."USAGE_VALUE" ;;
  }

  dimension: service_record_id {
    type: number
    sql: ${TABLE}."SERVICE_RECORD_ID" ;;
  }

  dimension: last_service_usage_value {
    type: number
    sql: ${TABLE}."LAST_SERVICE_USAGE_VALUE" ;;
  }

  dimension: next_service_usage_value {
    type: number
    sql: ${TABLE}."NEXT_SERVICE_USAGE_VALUE" ;;
  }

  dimension: current_usage_value {
    type: number
    sql: ${TABLE}."CURRENT_USAGE_VALUE" ;;
  }

  # hours until next service (usage based, not time based)
  dimension: until_next_service_usage {
    label: "Until Next Service - Usage"
    type: number
    sql: ROUND(${TABLE}."UNTIL_NEXT_SERVICE_USAGE") ;;
  }

  dimension: usage_percentage_remaining {
    type: number
    sql: ${TABLE}."USAGE_PERCENTAGE_REMAINING" ;;
  }

  dimension: usage_percentage {
    type: number
    sql: ${TABLE}."USAGE_PERCENTAGE" ;;
  }

  dimension: last_service_time_value {
    type: number
    sql: ${TABLE}."LAST_SERVICE_TIME_VALUE" ;;
  }

  dimension: next_service_time_value {
    type: number
    sql: ${TABLE}."NEXT_SERVICE_TIME_VALUE" ;;
  }

  dimension_group: next_service_time_value_corrected {
    label: "Date of Next Inspection"
    type: time
    sql: ${TABLE}."NEXT_SERVICE_TIME_VALUE_CORRECTED" ;;
  }

  dimension: current_time_value {
    type: number
    sql: ${TABLE}."CURRENT_TIME_VALUE" ;;
  }

  dimension_group: time_value_corrected {
    type: time
    sql: ${TABLE}."TIME_VALUE_CORRECTED" ;;
  }

  dimension_group: date_completed {
    type: time
    sql: ${TABLE}."DATE_COMPLETED" ;;
  }

  dimension: _next_service_time_value {
    hidden: yes
    type: number
    sql: ${TABLE}."_NEXT_SERVICE_TIME_VALUE" ;;
  }

  dimension: _current_time_value {
    hidden: yes
    type: number
    sql: ${TABLE}."_CURRENT_TIME_VALUE" ;;
  }

  # days to next service (if it is time based, not usage based)
  dimension: until_next_service_time {
    label: "Days Until Next Inspection"
    type: number
    sql: round(${TABLE}."UNTIL_NEXT_SERVICE_TIME") ;;
  }

  dimension: time_percentage_remaining {
    type: number
    sql: ${TABLE}."TIME_PERCENTAGE_REMAINING" ;;
  }

  dimension: time_percentage {
    type: number
    sql: ${TABLE}."TIME_PERCENTAGE" ;;
  }

  dimension: work_order_originator_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_ORIGINATOR_ID" ;;
  }

  dimension: work_order_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_ID" ;;
  }

  dimension: service_time_remaining_in_weeks {
    type: number
    sql: ${TABLE}."SERVICE_TIME_REMAINING_IN_WEEKS" ;;
  }

  dimension: maintenance_group_interval_name {
    type: string
    sql: ${TABLE}."MAINTENANCE_GROUP_INTERVAL_NAME" ;;
  }

  # Use until_next_service_time instead
  dimension: days_until_next_service {
    hidden: yes
    type: number
    sql: DATEDIFF('day', ${next_service_time_value_corrected_date}, current_date()) ;;
  }

  dimension: service_interval_type {
    type: string
    sql: case when UPPER(${maintenance_group_interval_name}) like '%ANSI%' then 'ANSI'
    when UPPER(${maintenance_group_interval_name}) like '%DOT %' or ${maintenance_group_interval_name} like '%90 Day%' then 'DOT'
    when UPPER(${maintenance_group_interval_name}) like '%ANNUAL%' then 'Annual'
    else 'PM' end ;;
  }

  dimension: service_interval_type_id {
    type: string
    sql: case when UPPER(${maintenance_group_interval_name}) like '%ANSI%' then 1
          when UPPER(${maintenance_group_interval_name}) like '%DOT %' or ${maintenance_group_interval_name} like '%90 Day%' then 2
          when UPPER(${maintenance_group_interval_name}) like '%ANNUAL%' then 3
          else 4 end ;;
  } #adding to sort visual axis
  # ANSI inspections are for aerial equipment only
  dimension: is_ANSI {
    type: yesno
    sql:
    UPPER(${maintenance_group_interval_name}) like '%ANSI%';;
  }

  dimension: is_annual {
    type: yesno
    sql: ${maintenance_group_interval_name} ilike '%Annual%'
    and ${maintenance_group_interval_name} not like '%DOT %';;
  }

  # DOT inspections are only for vehicles
  dimension: is_DOT {
    type: yesno
    sql: UPPER(${maintenance_group_interval_name}) like '%DOT %' OR ${maintenance_group_interval_name} like '%90 Day%' ;;
  }

  # Everything that's not ANSI or DOT is considered a PM
  dimension: is_PM {
    type: yesno
    sql:
    UPPER(${maintenance_group_interval_name}) not like '%ANSI%' and
    UPPER(${maintenance_group_interval_name}) not like '%ANNUAL%' and
    UPPER(${maintenance_group_interval_name}) not like '%DOT %' and
    UPPER(${maintenance_group_interval_name}) not like '%90 DAY%';;
  }

  dimension: overdue_usage {
    type: yesno
    sql:
     (${TABLE}."UNTIL_NEXT_SERVICE_TIME" < 0 AND ${TABLE}."UNTIL_NEXT_SERVICE_TIME" IS NOT NULL)
       OR
     (${TABLE}."UNTIL_NEXT_SERVICE_USAGE" < 0 AND ${TABLE}."UNTIL_NEXT_SERVICE_USAGE" IS NOT NULL);;
  }

  # Used for hyperlink in detail drill down, based on work_order_id and at request of Casey Flanegan 2022-06-13
  dimension: track_link_to_WO {
    label: "Link to WO"
    type: string
    sql: ${work_order_id} ;;
    html: <font color="blue "><u><a href="https://app.estrack.com/#/service/work-orders/{{ work_order_id._value }}/updates" target="_blank">T3 WO</a></font></u> ;;
  }


  measure: count {
    type: count
    drill_fields: [detail*]
  }
  measure: count_distinct {
    type: count_distinct
    sql: ${asset_id} ;;
    drill_fields: [ansi_dot_detail*]
  }

  measure: count_distinct_transportation {
    type: count_distinct
    sql: ${asset_id} ;;
    drill_fields: [transportation_detail*]
  }

  measure: until_next_ansi_service {
    type: sum
    sql: ${time_percentage} ;;
    value_format_name: percent_1
  }

  measure: service_overdue {
    type: sum
    filters: [service_time_remaining_in_weeks: "= -1"]
    sql: CASE WHEN ${service_time_remaining_in_weeks} is not null then 1 end ;;
    drill_fields: [detail*]
    link: {
      label: "View Only Overdue Assets"
      url: "{{ link }}&sorts=mv_asset_service_intervals.time_percentage+desc"
    }
    link: {
      label: "View Only Overdue On Rent Assets"
      url: "https://equipmentshare.looker.com/looks/96?&f[market_region_xwalk.market_name]={{ _filters['market_region_xwalk.market_name'] | url_encode }}&f[market_region_xwalk.region_name]={{ _filters['market_region_xwalk.region_name'] | url_encode }}"
    }
  }

  measure: overdue_ansi {
    label: "Overdue ANSI"
    type: count_distinct
    filters: [service_time_remaining_in_weeks: "-1", is_ANSI: "yes"]
    # sql: CASE WHEN ${service_time_remaining_in_weeks} is not null then 1 end ;;
    sql: ${asset_id} ;;
    drill_fields: [ansi_dot_detail*]
  }
  measure: total_ansi {
    label: "Total ANSI"
    type: count_distinct
    filters: [is_ANSI: "yes"]
    sql: ${asset_id} ;;
    drill_fields: [detail*]
  }

  measure: overdue_annual {
    label: "Overdue Annual"
    type: count_distinct
    filters: [service_time_remaining_in_weeks: "-1", is_annual: "yes"]
    # sql: CASE WHEN ${service_time_remaining_in_weeks} is not null then 1 end ;;
    sql: ${asset_id} ;;
    drill_fields: [ansi_dot_detail*]
  }
  measure: total_annual {
    label: "Total Annual"
    type: count_distinct
    filters: [is_annual: "yes"]
    sql: ${asset_id} ;;
    drill_fields: [detail*]
  }

  measure: overdue_dot {
    label: "Overdue DOT"
    type: count_distinct
    filters: [service_time_remaining_in_weeks: "-1", is_DOT: "yes"]
    # sql: CASE WHEN ${service_time_remaining_in_weeks} is not null then 1 end ;;
    sql: ${asset_id} ;;
    drill_fields: [ansi_dot_detail*]
  }
  measure: total_dot {
    label: "Total DOT"
    type: count_distinct
    filters: [is_DOT: "yes"]
    sql: ${asset_id} ;;
    drill_fields: [detail*]
  }

  measure: overdue_pm {
    label: "Overdue PM"
    type: count_distinct
    filters: [overdue_usage: "yes", is_PM: "yes"]
    sql: ${asset_id} ;;
    # sql: CASE WHEN ${service_time_remaining_in_weeks} is not null then 1 end ;;
    drill_fields: [detail*]
  }
  measure: total_pm {
    label: "Total PM"
    type: count_distinct
    filters: [is_PM: "yes"]
    sql: ${asset_id} ;;
    drill_fields: [detail*]
  }
  dimension: overdue {
    type: string
    sql: case when (${service_interval_type} in ('ANSI','DOT','Annual') and ${service_time_remaining_in_weeks}=-1)
    or (${service_interval_type}='PM' and ${overdue_usage}='yes') then 'Overdue'
    else 'Other'
    End;;
  }

  measure: service_due_this_week {
    type: sum
    filters: [service_time_remaining_in_weeks: "= 0"]
    sql: CASE WHEN ${service_time_remaining_in_weeks} is not null then 1 end  ;;
    drill_fields: [detail*]
    link: {
      label: "View Only This Weeks Assets"
      url: "{{ link }}&sorts=mv_asset_service_intervals.time_percentage+desc"
    }
  }

  measure: service_due_next_four_weeks{
    type: sum
    filters: [service_time_remaining_in_weeks: "= 1"]
    sql: CASE WHEN ${service_time_remaining_in_weeks} is not null then 1 end  ;;
    drill_fields: [detail*]
    link: {
      label: "View Only Next Four Weeks Assets"
      url: "{{ link }}&sorts=mv_asset_service_intervals.time_percentage+desc"
    }
  }

  measure: service_due_over_five_plus_weeks{
    type: sum
    filters: [service_time_remaining_in_weeks: "= 5"]
    sql: CASE WHEN ${service_time_remaining_in_weeks} is not null then 1 end  ;;
    drill_fields: [detail*]
    link: {
      label: "View Only Five Plus Week Assets"
      url: "{{ link }}&sorts=mv_asset_service_intervals.time_percentage+desc"
    }
  }

  measure: service_total_due {
    type: sum
    sql: CASE WHEN ${service_time_remaining_in_weeks} is not null then 1 end  ;;
  }

  measure: service_percent_overdue {
    type: number
    sql: 1.0 * ${service_overdue}/case when ${service_total_due} = 0 then null else ${service_total_due} end ;;
    value_format_name: percent_1
    drill_fields: [detail*]
    link: {
      label: "View Only Overdue Assets"
      url: "{{ link }}&sorts=mv_asset_service_intervals.time_percentage+desc"
    }
  }

  measure: service_percent_this_week {
    type: number
    sql: 1.0 * ${service_due_this_week}/case when ${service_total_due} = 0 then null else ${service_total_due} end ;;
    value_format_name: percent_1
    drill_fields: [detail*]
    link: {
      label: "View Only This Weeks Assets"
      url: "{{ link }}&sorts=mv_asset_service_intervals.time_percentage+desc"
    }
  }

  measure: service_percent_next_four_weeks {
    type: number
    sql: 1.0 * ${service_due_next_four_weeks}/case when ${service_total_due} = 0 then null else ${service_total_due} end ;;
    value_format_name: percent_1
    drill_fields: [detail*]
    link: {
      label: "View Only Next Four Weeks Assets"
      url: "{{ link }}&sorts=mv_asset_service_intervals.time_percentage+desc"
    }
  }

  measure: service_percent_five_plus_weeks {
    type: number
    sql: 1.0 * ${service_due_over_five_plus_weeks}/case when ${service_total_due} = 0 then null else ${service_total_due} end ;;
    value_format_name: percent_1
    drill_fields: [detail*]
    link: {
      label: "View Only Five Plus Week Assets"
      url: "{{ link }}&sorts=mv_asset_service_intervals.time_percentage+desc"
    }
  }

  dimension: ansi_status {
    type: string
    sql: case when ${service_time_remaining_in_weeks} = -1 then 'Overdue'
          when ${service_time_remaining_in_weeks} = 0 then 'Due This Week'
          when ${service_time_remaining_in_weeks} = 1 and ${service_time_remaining_in_weeks} <= 4 then 'Due In Next Four Weeks'
          when ${service_time_remaining_in_weeks} = 5 then 'Due In Five Plus Weeks'
          end;;
  }

  measure: count_assets_mgi {
    type: count_distinct
    sql: ${asset_id};;
    drill_fields: [companies.name,date_created_month_name,count_assets_month]
  }

  measure: count_assets_month {
    type: count_distinct
    sql: ${asset_id} ;;
    drill_fields: [asset_id,date_created_date,maintenance_group_id]
  }

  set: detail {
    fields: [
      asset_id,
      assets.make_and_model,
      markets.name,
      asset_status_key_values.value,
      until_next_service_time,
      until_next_service_usage,
      track_link_to_WO,
      asset_location.location_info_date,
      asset_location.location_source,
      asset_location.address,
      asset_location.map_link]
  }

  set: ansi_dot_detail {
    fields: [
      asset_id,
      assets.make_and_model,
      assets_aggregate.oec,
      markets.name,
      asset_status_key_values.value,
      until_next_service_time,
      until_next_service_usage,
      maintenance_group_interval_name,
      track_link_to_WO,
      asset_location.location_info_date,
      asset_location.location_source,
      asset_location.address,
      asset_location.map_link]
  }

  set: transportation_detail {
    fields: [
      asset_id,
      assets.make_and_model,
      users.driver,
      markets.name,
      asset_status_key_values.value,
      until_next_service_time,
      until_next_service_usage,
      maintenance_group_interval_name,
      track_link_to_WO,
      asset_location.location_info_date,
      asset_location.location_source,
      asset_location.address,
      asset_location.map_link]
  }
}

view: asset_service_intervals_with_exxon_inspections {
  derived_table: {
    sql:
with prep as (
    select m.market_region_name as region
        , m.market_district as district
        , m.market_name as market
        , m.market_type
        , asi.asset_id
        , a.asset_equipment_class_name as class
        , a.asset_equipment_make as make
        , a.asset_equipment_make_and_model as make_and_model
        , a.asset_current_oec as oec
        , a.asset_inventory_status
        , asi.until_next_service_time as days_until_next_inspection
        , asi.until_next_service_usage
        , asi.maintenance_group_interval_name

        , round(asi.work_order_id, 0)::STRING as work_order_id
        --asset location
        , iff(a.asset_inventory_status = 'On Rent', 'On Rent', 'Other') as on_rent
        , iff(
            ((asi.UNTIL_NEXT_SERVICE_TIME < 0 AND asi.UNTIL_NEXT_SERVICE_TIME IS NOT NULL)
                OR (ASI.UNTIL_NEXT_SERVICE_USAGE < 0 AND ASI.UNTIL_NEXT_SERVICE_USAGE IS NOT NULL))
            , TRUE, FALSE) as overdue_usage
        , case
            when UPPER(asi.maintenance_group_interval_name) like '%ANSI%' then 'ANSI'
            when UPPER(asi.maintenance_group_interval_name) like '%DOT %' or asi.maintenance_group_interval_name ilike '%90 Day%' then 'DOT'
            when UPPER(asi.maintenance_group_interval_name) like '%ANNUAL%' then 'Annual'
            else 'PM' end as service_interval_type
        , case
            when (service_interval_type in ('ANSI','DOT','Annual') and asi.service_time_remaining_in_weeks = -1)
                or (service_interval_type = 'PM' and overdue_usage = TRUE) then 'Overdue'
            else 'Other' end as overdue
        , case
            when (asi.service_time_remaining_in_weeks = 0 OR asi.service_time_remaining_in_weeks = 1) AND asi.until_next_service_usage is null then 'Upcoming'
            when asi.usage_percentage_remaining < 0.1 and asi.usage_percentage_remaining > 0 then 'Upcoming'
            when asi.maintenance_group_interval_name ilike '%15000 Mile%' AND round(asi.until_next_service_usage) <= 2000 then 'Upcoming'
            else 'Not Upcoming' end as upcoming
    from "ES_WAREHOUSE"."PUBLIC"."ASSET_SERVICE_INTERVALS" asi
    join FLEET_OPTIMIZATION.GOLD.DIM_ASSETS_FLEET_OPT a
        on asi.asset_id = a.asset_id
    join FLEET_OPTIMIZATION.GOLD.DIM_MARKETS_FLEET_OPT m
        on m.market_key = iff(a.asset_maintenance_service_provider_market_id <> -1, a.asset_maintenance_service_provider_market_key, a.asset_rental_market_key)
    where m.market_company_id in (select company_id from FLEET_OPTIMIZATION.GOLD.DIM_COMPANIES_FLEET_OPT where COMPANY_IS_EQUIPMENTSHARE_COMPANY)
)

select region
    , district
    , market
    , market_type
    , asset_id
    , class
    , make
    , make_and_model
    , oec
    , asset_inventory_status
    , days_until_next_inspection
    , until_next_service_usage
    , maintenance_group_interval_name
    , service_interval_type
    , work_order_id
    , on_rent
    , overdue
    , upcoming
from prep

union

select dm.market_region_name as region
    , dm.market_district as district
    , dm.market_name as market
    , dm.market_type
    , r.asset_id
    , da.asset_equipment_class_name as class
    , da.asset_equipment_make as make
    , da.asset_equipment_make_and_model as make_and_model
    , da.asset_current_oec as oec
    , da.asset_inventory_status
    -- , greatest(r.start_date::DATE, coalesce(wo.last_exxon_inspection, '1970-01-01'))
    , datediff(day, current_date, dateadd(day, 90, greatest(r.start_date::DATE, coalesce(wo.last_exxon_inspection, '1970-01-01')))) as days_until_next_inspection
    , null as until_next_service_usage
    , 'Exxon 90 Day Inspection' as maintenance_group_interval_name
    , 'Exxon 90 Day Inspection' as service_interval_type
    , owo.work_order_id
    , 'On Rent' as on_rent
    , iff(days_until_next_inspection <= 0, 'Overdue', 'Other') as overdue
    , iff(days_until_next_inspection <= 10 and days_until_next_inspection > 0, 'Upcoming', 'Not Upcoming') as upcoming
from ES_WAREHOUSE.PUBLIC.RENTALS r
join ES_WAREHOUSE.PUBLIC.ORDERS o
    on r.order_id = o.order_id
left join (
        select asset_id, max(date_completed::DATE) as last_exxon_inspection
        from ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS wo
        join ES_WAREHOUSE.WORK_ORDERS.WORK_ORDER_COMPANY_TAGS woct
            on woct.work_order_id = wo.work_order_id
                and woct.company_tag_id = 22239 --Exxon 90 Day Inspection
        where wo.archived_date is null
            and wo.work_order_status_name not ilike '%Open%'
        group by 1
    ) wo
    on wo.asset_id = r.asset_id
left join (
        select wo.asset_id, listagg(wo.work_order_id, ' / ') as work_order_id
        from ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS wo
        join ES_WAREHOUSE.WORK_ORDERS.WORK_ORDER_COMPANY_TAGS woct
            on woct.work_order_id = wo.work_order_id
                and woct.company_tag_id = 22239 --Exxon 90 Day Inspection
        where wo.archived_date is null
            and wo.work_order_status_name ilike '%Open%'
        group by 1
    ) owo
    on owo.asset_id = r.asset_id
join FLEET_OPTIMIZATION.GOLD.DIM_ASSETS_FLEET_OPT da
    on da.asset_id = r.asset_id
        and da.asset_equipment_type = 'equipment'
join FLEET_OPTIMIZATION.GOLD.DIM_MARKETS_FLEET_OPT dm
    on dm.market_key = iff(da.asset_maintenance_service_provider_market_id <> -1, da.asset_maintenance_service_provider_market_key, da.asset_rental_market_key)
        and dm.market_company_id in (select company_id from FLEET_OPTIMIZATION.GOLD.DIM_COMPANIES_FLEET_OPT where COMPANY_IS_EQUIPMENTSHARE_COMPANY)
where o.company_id in (select company_id from ES_WAREHOUSE.PUBLIC.COMPANIES c where c.name ilike '%exxon%') --on rent to exxon
    and r.rental_status_id = 5 --On Rent
    and r.asset_id is not null
    and dm.market_id=44836 --8.20.25 HL- filtering to just XOM Baton Rouge, other XOMs do not require yet.
;;
  }

  dimension: region {
    type: string
    sql: ${TABLE}.region ;;
  }
  dimension: district {
    type: string
    sql: ${TABLE}.district ;;
  }
  dimension: market {
    type: string
    sql: ${TABLE}.market ;;
  }
  dimension: market_type {
    type: string
    sql: ${TABLE}.market_type ;;
  }
  dimension: asset_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.asset_id ;;
    html: <a href="https://app.estrack.com/#/assets/all/asset/{{ asset_id._value }}/service" target="new" style="color: #0063f3; text-decoration: underline;">{{ asset_id._value }}</a> ;;
  }
  measure: distinct_asset_count {
    type: count_distinct
    sql: ${asset_id} ;;
    drill_fields: [asset_id
      , make_and_model
      , oec
      , market
      , asset_inventory_status
      , days_until_next_inspection
      , until_next_service_usage
      , maintenance_group_interval_name
      , work_order_id
      , asset_location.location_info_date
      , asset_location.location_source
      , asset_location.address
      , asset_location.map_link
      ]
  }
  dimension: class {
    type: string
    sql: ${TABLE}.class ;;
  }
  dimension: make {
    type: string
    sql: ${TABLE}.make ;;
  }
  dimension: make_and_model {
    type: string
    sql: ${TABLE}.make_and_model ;;
  }
  dimension: oec {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.oec ;;
  }
  dimension: asset_inventory_status {
    type: string
    sql: ${TABLE}.asset_inventory_status ;;
  }
  dimension: days_until_next_inspection {
    type: number
    sql: ${TABLE}.days_until_next_inspection ;;
  }
  dimension: until_next_service_usage {
    type: number
    sql: ${TABLE}.until_next_service_usage ;;
  }
  dimension: maintenance_group_interval_name {
    type: string
    sql: ${TABLE}.maintenance_group_interval_name ;;
  }
  dimension: service_interval_type {
    type: string
    sql: ${TABLE}.service_interval_type ;;
  }
  dimension: work_order_id {
    type: string
    sql: ${TABLE}.work_order_id ;;
    html: <a href="https://app.estrack.com/#/service/work-orders/{{ work_order_id._value }}" target="new" style="color: #0063f3; text-decoration: underline;">{{ work_order_id._value }}</a> ;;
  }
  dimension: on_rent {
    type: string
    sql: ${TABLE}.on_rent ;;
  }
  dimension: overdue {
    type: string
    sql: ${TABLE}.overdue;;
  }
  dimension: upcoming {
    type: string
    sql: ${TABLE}.upcoming ;;
  }
}
