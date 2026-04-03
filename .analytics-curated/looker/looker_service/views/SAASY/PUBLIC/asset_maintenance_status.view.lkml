view: asset_maintenance_status {
  derived_table: {
    sql: select * from "SAASY"."PUBLIC"."ASSET_MAINTENANCE_STATUS" where is_deleted = false ;;
  }
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ID" ;;
  }
  dimension_group: _es_load_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_LOAD_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
    value_format_name: id
    html: <font color="blue "><u><a href="https://app.estrack.com/#/assets/all/asset/{{ asset_id._value }}/service/overview" target="_blank">{{ asset_id._value }}</a></font></u> ;;
  }
  dimension: business_key {
    type: string
    sql: ${TABLE}."BUSINESS_KEY" ;;
  }
  dimension_group: created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."CREATED_AT" ;;
  }
  dimension: current_secondary_usage_value {
    type: number
    sql: ${TABLE}."CURRENT_SECONDARY_USAGE_VALUE" ;;
  }
  dimension: current_time_value {
    type: number
    sql: ${TABLE}."CURRENT_TIME_VALUE" ;;
  }
  dimension: current_usage_value {
    type: number
    sql: ${TABLE}."CURRENT_USAGE_VALUE" ;;
  }
  dimension_group: date_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."DATE_CREATED" ;;
  }
  dimension: hours {
    type: number
    sql: ${TABLE}."HOURS" ;;
  }
  dimension: is_deleted {
    type: yesno
    sql: ${TABLE}."IS_DELETED" ;;
  }
  dimension: last_service_secondary_usage_value {
    type: number
    sql: ${TABLE}."LAST_SERVICE_SECONDARY_USAGE_VALUE" ;;
  }
  dimension: last_service_time_value {
    type: number
    sql: ${TABLE}."LAST_SERVICE_TIME_VALUE" ;;
  }
  dimension: last_service_usage_value {
    type: number
    sql: ${TABLE}."LAST_SERVICE_USAGE_VALUE" ;;
  }
  dimension: maintenance_group_id {
    type: number
    sql: ${TABLE}."MAINTENANCE_GROUP_ID" ;;
  }
  dimension: maintenance_group_interval_id {
    type: number
    sql: ${TABLE}."MAINTENANCE_GROUP_INTERVAL_ID" ;;
  }
  dimension: next_service_secondary_usage_value {
    type: number
    sql: ${TABLE}."NEXT_SERVICE_SECONDARY_USAGE_VALUE" ;;
  }
  dimension: next_service_time_value {
    type: number
    sql: ${TABLE}."NEXT_SERVICE_TIME_VALUE" ;;
  }
  dimension: next_service_usage_value {
    type: number
    sql: ${TABLE}."NEXT_SERVICE_USAGE_VALUE" ;;
  }
  dimension: odometer {
    type: number
    sql: ${TABLE}."ODOMETER" ;;
  }
  dimension: repeat {
    type: yesno
    sql: ${TABLE}."REPEAT" ;;
  }
  dimension: secondary_usage_interval_id {
    type: number
    sql: ${TABLE}."SECONDARY_USAGE_INTERVAL_ID" ;;
  }
  dimension: secondary_usage_percentage {
    type: number
    sql: ${TABLE}."SECONDARY_USAGE_PERCENTAGE" ;;
  }
  dimension: secondary_usage_percentage_remaining {
    type: number
    sql: ${TABLE}."SECONDARY_USAGE_PERCENTAGE_REMAINING" ;;
  }
  dimension: secondary_usage_unit_id {
    type: number
    sql: ${TABLE}."SECONDARY_USAGE_UNIT_ID" ;;
  }
  dimension: secondary_usage_value {
    type: number
    sql: ${TABLE}."SECONDARY_USAGE_VALUE" ;;
  }
  dimension: service_interval_id {
    type: number
    sql: ${TABLE}."SERVICE_INTERVAL_ID" ;;
  }
  dimension: service_interval_name {
    type: string
    sql: ${TABLE}."SERVICE_INTERVAL_NAME" ;;
  }
  dimension: service_record_id {
    type: number
    sql: ${TABLE}."SERVICE_RECORD_ID" ;;
  }
  dimension: time_interval_id {
    type: number
    sql: ${TABLE}."TIME_INTERVAL_ID" ;;
  }
  dimension: time_percentage {
    type: number
    sql: ${TABLE}."TIME_PERCENTAGE" ;;
  }
  dimension: time_percentage_remaining {
    type: number
    sql: ${TABLE}."TIME_PERCENTAGE_REMAINING" ;;
  }
  dimension: time_unit_id {
    type: number
    sql: ${TABLE}."TIME_UNIT_ID" ;;
  }
  dimension: time_value {
    type: number
    sql: ${TABLE}."TIME_VALUE" ;;
  }
  dimension: trigger_exceeded {
    type: yesno
    sql: ${TABLE}."TRIGGER_EXCEEDED" ;;
  }
  dimension: until_next_service_secondary_usage {
    type: number
    sql: ${TABLE}."UNTIL_NEXT_SERVICE_SECONDARY_USAGE" ;;
  }
  dimension: until_next_service_time {
    type: number
    value_format_name: decimal_1
    sql: ${TABLE}."UNTIL_NEXT_SERVICE_TIME" ;;
  }
  dimension: until_next_service_usage {
    type: number
    value_format_name: decimal_2
    sql: ${TABLE}."UNTIL_NEXT_SERVICE_USAGE" ;;
  }
  dimension_group: updated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."UPDATED_AT" ;;
  }
  dimension: usage_interval_id {
    type: number
    sql: ${TABLE}."USAGE_INTERVAL_ID" ;;
  }
  dimension: usage_percentage {
    type: number
    sql: ${TABLE}."USAGE_PERCENTAGE" ;;
  }
  dimension: usage_percentage_remaining {
    type: number
    sql: ${TABLE}."USAGE_PERCENTAGE_REMAINING" ;;
  }
  dimension: usage_unit_id {
    type: number
    sql: ${TABLE}."USAGE_UNIT_ID" ;;
  }
  dimension: usage_value {
    type: number
    sql: ${TABLE}."USAGE_VALUE" ;;
  }
  dimension: version_number {
    type: number
    sql: ${TABLE}."VERSION_NUMBER" ;;
  }
  dimension: warn_exceeded {
    type: yesno
    sql: ${TABLE}."WARN_EXCEEDED" ;;
  }
  dimension: work_order_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_ID" ;;
    value_format_name: id
    html: <font color="blue "><u><a href="https://app.estrack.com/#/service/work-orders/{{ work_order_id._value }}/updates" target="_blank">{{ work_order_id._value }}</a></font></u> ;;
  }
  dimension: work_order_originator_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_ORIGINATOR_ID" ;;
  }
  measure: count {
    type: count
    drill_fields: [id, service_interval_name]
  }
  dimension: due_this_week {
    type: yesno
    sql:iff(${until_next_service_time} between 0 and 7, true, false) ;; #Should I include the > -1???
  }
  measure: service_total_due {
    type: sum
    sql: CASE WHEN ${until_next_service_time} is not null then 1 end  ;;
  }
  measure: service_due_this_week {
    type: sum
    filters: [due_this_week: "yes"]
    sql:
      CASE
        WHEN ${until_next_service_time} is not null then 1
      end  ;;
    drill_fields: [detail*]
    # link: {
    #   label: "View Only This Weeks Assets"
    #   url: "{{ link }}&sorts=mv_asset_service_intervals.time_percentage+desc"
    # }
  }
  measure: service_percent_this_week {
    type: number
    sql: 1.0 * ${service_due_this_week}/case when ${service_total_due} = 0 then null else ${service_total_due} end ;;
    value_format_name: percent_1
    drill_fields: [detail*]
    # link: {
    #   label: "View Only This Weeks Assets"
    #   url: "{{ link }}&sorts=mv_asset_service_intervals.time_percentage+desc"
    # }
  }
  dimension: due_next_four_weeks {
    type: yesno
    sql:iff((dateadd(day, ${until_next_service_time}, current_date)) < date_trunc(week, dateadd(week, 5, current_date)) and ${until_next_service_time} > -1, true, false) ;;
  }
  measure: service_due_next_four_weeks{
    type: sum
    filters: [due_next_four_weeks: "yes"]
    sql: CASE WHEN ${until_next_service_time} is not null then 1 end  ;;
    drill_fields: [detail*]
    # link: {
    #   label: "View Only Next Four Weeks Assets"
    #   url: "{{ link }}&sorts=mv_asset_service_intervals.time_percentage+desc"
    # }
  }
  measure: service_percent_next_four_weeks {
    type: number
    sql: 1.0 * ${service_due_next_four_weeks}/case when ${service_total_due} = 0 then null else ${service_total_due} end ;;
    value_format_name: percent_1
    drill_fields: [detail*]
    # link: {
    #   label: "View Only Next Four Weeks Assets"
    #   url: "{{ link }}&sorts=mv_asset_service_intervals.time_percentage+desc"
    # }
  }

  set: detail {
    fields: [
      asset_id,
      assets.make_and_model,
      markets.name,
      asset_status_key_values.value,
      until_next_service_time,
      until_next_service_usage,
      work_order_id,
      asset_location.location_info_date,
      asset_location.location_source,
      asset_location.address,
      asset_location.map_link]
  }
}

view: asset_maintenance_status_with_exxon_inspections {
  derived_table: {
    sql:
with prep as (
    select m.market_region_name as region
        , m.market_district as district
        , m.market_id
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
        , mgi.name as maintenance_group_interval_name

        , round(asi.work_order_id, 0)::STRING as work_order_id
        --asset location
        , iff(a.asset_inventory_status = 'On Rent', 'On Rent', 'Other') as on_rent
        , iff(
            ((asi.UNTIL_NEXT_SERVICE_TIME < 0 AND asi.UNTIL_NEXT_SERVICE_TIME IS NOT NULL)
                OR (ASI.UNTIL_NEXT_SERVICE_USAGE < 0 AND ASI.UNTIL_NEXT_SERVICE_USAGE IS NOT NULL))
            , TRUE, FALSE) as overdue_usage
        , case
            when UPPER(maintenance_group_interval_name) like '%ANSI%' then 'ANSI'
            when UPPER(maintenance_group_interval_name) like '%DOT %' or maintenance_group_interval_name ilike '%90 Day%' then 'DOT'
            when UPPER(maintenance_group_interval_name) like '%ANNUAL%' then 'Annual'
            else 'PM' end as service_interval_type
        , case
            when (service_interval_type in ('ANSI','DOT','Annual') and asi.until_next_service_time < 0) --Switched out asi.next_service_time_value for asi.until_next_service_time, asi.next_service_time_value has a floor at zero now 9/2025
                or (service_interval_type = 'PM' and overdue_usage = TRUE) then 'Overdue'
            else 'Other' end as overdue
        , case
            when (asi.until_next_service_time = 0 OR (asi.until_next_service_time between 0 and 30)) AND asi.until_next_service_usage is null then 'Upcoming' --Switched out asi.next_service_time_value for asi.until_next_service_time, asi.next_service_time_value has a floor at zero now 9/2025
            when asi.usage_percentage_remaining < 0.1 and asi.usage_percentage_remaining > 0 then 'Upcoming'
            when maintenance_group_interval_name ilike '%15000 Mile%' AND round(asi.until_next_service_usage) <= 2000 then 'Upcoming'
            else 'Not Upcoming' end as upcoming
        , iff(a.asset_company_key in (select company_key from FLEET_OPTIMIZATION.GOLD.DIM_COMPANIES_FLEET_OPT where company_is_equipmentshare_company), true, false) as asset_es_owned
        , a.asset_equipment_type
    -- from "ES_WAREHOUSE"."PUBLIC"."ASSET_SERVICE_INTERVALS" asi
    from saasy.public.asset_maintenance_status asi
    join FLEET_OPTIMIZATION.GOLD.DIM_ASSETS_FLEET_OPT a
        on asi.asset_id = a.asset_id
    join FLEET_OPTIMIZATION.GOLD.DIM_MARKETS_FLEET_OPT m
        on m.market_key = iff(a.asset_maintenance_service_provider_market_id <> -1, a.asset_maintenance_service_provider_market_key, a.asset_rental_market_key)
          and m.reporting_market
    left join ES_WAREHOUSE.PUBLIC.MAINTENANCE_GROUP_INTERVALS mgi
        on asi.maintenance_group_interval_id = mgi.maintenance_group_interval_id
    where m.market_company_id in (select company_id from FLEET_OPTIMIZATION.GOLD.DIM_COMPANIES_FLEET_OPT where COMPANY_IS_EQUIPMENTSHARE_COMPANY)
      and asi.is_deleted = FALSE
)

select p.region
    , p.district
    , p.market_id
    , p.market
    , p.market_type
    , p.asset_id
    , p.asset_equipment_type
    , p.class
    , p.make
    , p.make_and_model
    , p.asset_es_owned
    , p.oec
    , p.asset_inventory_status
    , p.days_until_next_inspection
    , p.until_next_service_usage
    , p.maintenance_group_interval_name
    , p.service_interval_type
    , p.work_order_id
    , p.on_rent
    , p.overdue
    , p.upcoming
from prep p

union

select dm.market_region_name as region
    , dm.market_district as district
    , dm.market_id
    , dm.market_name as market
    , dm.market_type
    , r.asset_id
    , da.asset_equipment_type
    , da.asset_equipment_class_name as class
    , da.asset_equipment_make as make
    , da.asset_equipment_make_and_model as make_and_model
    , iff(da.asset_company_key in (select company_key from FLEET_OPTIMIZATION.GOLD.DIM_COMPANIES_FLEET_OPT where company_is_equipmentshare_company), true, false) as asset_es_owned
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

union

select dm.market_region_name as region
    , dm.market_district as district
    , dm.market_id
    , dm.market_name as market
    , market_type
    , null as asset_id
    , null as asset_equipment_type
    , null as class
    , null as make
    , null as make_and_model
    , null as asset_es_owned
    , null as oec
    , null as daasset_inventory_status
    -- , greatest(r.start_date::DATE, coalesce(wo.last_exxon_inspection, '1970-01-01'))
    , null as days_until_next_inspection
    , null as until_next_service_usage
    , 'ANSI' as maintenance_group_interval_name
    , 'ANSI' as service_interval_type
    , null as work_order_id
    , null as on_rent
    , null as overdue
    , null as upcoming
from FLEET_OPTIMIZATION.GOLD.DIM_MARKETS_FLEET_OPT dm
left join (select distinct market_id, service_interval_type from prep) p
    on p.market_id = dm.market_id
        and p.service_interval_type = 'ANSI'
where dm.reporting_market and p.market_id is null --No ANSI's for that market

union

select dm.market_region_name as region
    , dm.market_district as district
    , dm.market_id
    , dm.market_name as market
    , market_type
    , null as asset_id
    , null as asset_equipment_type
    , null as class
    , null as make
    , null as make_and_model
    , null as asset_es_owned
    , null as oec
    , null as daasset_inventory_status
    -- , greatest(r.start_date::DATE, coalesce(wo.last_exxon_inspection, '1970-01-01'))
    , null as days_until_next_inspection
    , null as until_next_service_usage
    , 'Annual' as maintenance_group_interval_name
    , 'Annual' as service_interval_type
    , null as work_order_id
    , null as on_rent
    , null as overdue
    , null as upcoming
from FLEET_OPTIMIZATION.GOLD.DIM_MARKETS_FLEET_OPT dm
left join (select distinct market_id, service_interval_type from prep) p
    on p.market_id = dm.market_id
        and p.service_interval_type = 'Annual'
where dm.reporting_market and p.market_id is null --No Annuals for that market

union

select dm.market_region_name as region
    , dm.market_district as district
    , dm.market_id
    , dm.market_name as market
    , market_type
    , null as asset_id
    , null as asset_equipment_type
    , null as class
    , null as make
    , null as make_and_model
    , null as asset_es_owned
    , null as oec
    , null as daasset_inventory_status
    -- , greatest(r.start_date::DATE, coalesce(wo.last_exxon_inspection, '1970-01-01'))
    , null as days_until_next_inspection
    , null as until_next_service_usage
    , 'DOT' as maintenance_group_interval_name
    , 'DOT' as service_interval_type
    , null as work_order_id
    , null as on_rent
    , null as overdue
    , null as upcoming
from FLEET_OPTIMIZATION.GOLD.DIM_MARKETS_FLEET_OPT dm
left join (select distinct market_id, service_interval_type from prep) p
    on p.market_id = dm.market_id
        and p.service_interval_type = 'DOT'
where dm.reporting_market and p.market_id is null --No DOTs for that market

union

select dm.market_region_name as region
    , dm.market_district as district
    , dm.market_id
    , dm.market_name as market
    , market_type
    , null as asset_id
    , null as asset_equipment_type
    , null as class
    , null as make
    , null as make_and_model
    , null as asset_es_owned
    , null as oec
    , null as daasset_inventory_status
    -- , greatest(r.start_date::DATE, coalesce(wo.last_exxon_inspection, '1970-01-01'))
    , null as days_until_next_inspection
    , null as until_next_service_usage
    , 'PM' as maintenance_group_interval_name
    , 'PM' as service_interval_type
    , null as work_order_id
    , null as on_rent
    , null as overdue
    , null as upcoming
from FLEET_OPTIMIZATION.GOLD.DIM_MARKETS_FLEET_OPT dm
left join (select distinct market_id, service_interval_type from prep) p
    on p.market_id = dm.market_id
        and p.service_interval_type = 'PM'
where dm.reporting_market and p.market_id is null --No PM for that market
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
  dimension: market_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.market_id ;;
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
  dimension: asset_es_owned {
    type: yesno
    sql: ${TABLE}.asset_es_owned ;;
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
  measure: overdue_distinct_asset_count {
    type: count_distinct
    sql: ${asset_id} ;;
    filters: [overdue: "Overdue"]
    html: {{overdue_distinct_asset_count._rendered_value}} assets | {{overdue_distinct_asset_oec._rendered_value}} OEC ;;
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
  measure: upcoming_distinct_asset_count {
    type: count_distinct
    sql: ${asset_id} ;;
    filters: [upcoming: "Upcoming"]
    html: {{upcoming_distinct_asset_count._rendered_value}} assets | {{upcoming_distinct_asset_oec._rendered_value}} OEC ;;
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
  measure: distinct_asset_oec {
    type: sum_distinct
    sql_distinct_key: ${asset_id} ;;
    value_format_name: usd_0
    sql: ${oec} ;;
  }
  measure: overdue_distinct_asset_oec {
    type: sum_distinct
    sql_distinct_key: ${asset_id} ;;
    filters: [overdue: "Overdue"]
    value_format_name: usd_0
    sql: ${oec} ;;
  }
  measure: upcoming_distinct_asset_oec {
    type: sum_distinct
    sql_distinct_key: ${asset_id} ;;
    filters: [upcoming: "Upcoming"]
    value_format_name: usd_0
    sql: ${oec} ;;
  }
  dimension: asset_inventory_status {
    type: string
    sql: ${TABLE}.asset_inventory_status ;;
  }
  dimension: days_until_next_inspection {
    type: number
    value_format_name: decimal_0
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
  dimension: due_this_week {
    type: yesno
    sql:iff(${days_until_next_inspection} between 0 and 7, true, false) ;; #Should I include the > -1???
  }
  measure: service_total_due {
    type: sum
    sql: CASE WHEN ${days_until_next_inspection} is not null then 1 end  ;;
  }
  measure: service_due_this_week {
    type: sum
    filters: [due_this_week: "yes"]
    sql:
      CASE
        WHEN ${days_until_next_inspection} is not null then 1
      end  ;;
    drill_fields: [detail*]
    # link: {
    #   label: "View Only This Weeks Assets"
    #   url: "{{ link }}&sorts=mv_asset_service_intervals.time_percentage+desc"
    # }
  }


  measure: service_percent_this_week {
    type: number
    sql: 1.0 * ${service_due_this_week}/case when ${service_total_due} = 0 then null else ${service_total_due} end ;;
    value_format_name: percent_1
    drill_fields: [detail*]
    # link: {
    #   label: "View Only This Weeks Assets"
    #   url: "{{ link }}&sorts=mv_asset_service_intervals.time_percentage+desc"
    # }
  }
  dimension: due_next_four_weeks {
    type: yesno
    sql:iff(${days_until_next_inspection} between 0 and 30, true, false) ;;
  }
  measure: service_due_next_four_weeks{
    type: sum
    filters: [due_next_four_weeks: "yes"]
    sql: CASE WHEN ${days_until_next_inspection} is not null then 1 end  ;;
    drill_fields: [detail*]
    # link: {
    #   label: "View Only Next Four Weeks Assets"
    #   url: "{{ link }}&sorts=mv_asset_service_intervals.time_percentage+desc"
    # }
  }
  measure: service_percent_next_four_weeks {
    type: number
    sql: 1.0 * ${service_due_next_four_weeks}/case when ${service_total_due} = 0 then null else ${service_total_due} end ;;
    value_format_name: percent_1
    drill_fields: [detail*]
    # link: {
    #   label: "View Only Next Four Weeks Assets"
    #   url: "{{ link }}&sorts=mv_asset_service_intervals.time_percentage+desc"
    # }
  }
  set: detail {
    fields: [asset_id
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
  dimension: ansi_flag {
    type: yesno
    sql: iff(${service_interval_type} ilike '%ANSI%', true, false) ;;
  }
  measure: overdue_ansi {
    label: "Overdue ANSI"
    type: count_distinct
    filters: [overdue: "Overdue", service_interval_type: "ANSI"]
    sql: ${asset_id} ;;
  }
  measure: overdue_on_rent_ANSI {
    type: count_distinct
    filters: [on_rent: "On Rent", overdue: "Overdue", service_interval_type: "ANSI"]
    sql: ${asset_id} ;;
  }
  dimension: dot_asset_flag {
    type: yesno
    sql:
case
  when (${asset_es_owned} and ${TABLE}.asset_equipment_type <> 'equipment') then TRUE
  when (${asset_es_owned} and ${TABLE}.asset_equipment_type = 'equipment' and ${service_interval_type} = 'DOT') then TRUE
  when (${asset_es_owned} and ${class} in (
    'Delivery Trailer'
    , 'Delivery Trucks'
    , 'Dual Axle Dump Truck, 10 - 12 Yd'
    , 'Office Trailer, 8%20%'
    , 'Service Truck'
    , 'Single Axle Dump Truck, 3/4 Yd - Diesel'
    , 'Single Axle Dump Truck, 5/6 Yd - Diesel'
    , 'Water Truck 2,000 - 2,500 Gal - Diesel'
    , 'Water Truck 4,000 - 4,500 Gal  - Diesel')) then TRUE
  else FALSE end  ;;
  }
  measure: dot_assets {
    type: count_distinct
    filters: [dot_asset_flag: "yes"]
    sql: ${asset_id} ;;
  }
  measure: overdue_dot {
    type: count_distinct
    filters: [overdue: "Overdue", service_interval_type: "DOT"]
    sql: ${asset_id} ;;
  }
  measure: overdue_pm {
    type: count_distinct
    filters: [overdue: "Overdue", service_interval_type: "PM"]
    sql: ${asset_id} ;;
  }
  # dimension: market_oec {
  #   type: number
  #   value_format_name: usd
  #   sql: ${TABLE}.market_oec ;;
  # }
  # dimension: district_oec {
  #   type: number
  #   value_format_name: usd
  #   sql: ${TABLE}.district_oec ;;
  # }
  # dimension: region_oec {
  #   type: number
  #   value_format_name: usd
  #   sql: ${TABLE}.region_oec ;;
  # }
  # dimension: selected_hierarchy_oec {
  #   type: string
  #   sql: {% if market._in_query %}
  #         ${market_oec}
  #       {% elsif district._in_query %}
  #         ${district_oec}
  #       {% elsif region._in_query %}
  #         ${region_oec}
  #       {% else %}
  #         ${region_oec}
  #       {% endif %};;
  # }
  # dimension: selected_hierarchy_location {
  #   type: string
  #   sql: {% if market._in_query %}
  #         ${market}
  #       {% elsif district._in_query %}
  #         ${district}
  #       {% elsif region._in_query %}
  #         ${region}
  #       {% else %}
  #         ${region}
  #       {% endif %};;
  # }
  # measure: total_distinct_location_oec {
  #   type: sum_distinct
  #   sql_distinct_key: ${selected_hierarchy_location} ;;
  #   value_format_name: usd_0
  #   sql: ${selected_hierarchy_oec} ;;
  # }
  # measure: percent_of_total_oec {
  #   type: number
  #   value_format_name: percent_2
  #   sql: ${distinct_asset_oec} / nullifzero(${total_distinct_location_oec}) ;;
  # }
}
