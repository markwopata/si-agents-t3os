view: ool {

  derived_table: {
    sql:
    with
asset_summary as(
select ast.asset_id as final_asset_id, a.company_id as company_id, ast.last_checkin_timestamp AS last_checkin,ast.battery_voltage as battery_voltage, ast.location as jobsite, ast.rssi as rssi, t.tracker_id as tracker_id,
t.tracker_type_id as final_tracker_type_id, x.market_id as market_id, x.market_name as inventory_branch, x.region_name as region, x.DISTRICT as district, a.make as make, a.model as model,
--    ast.location, ast.engine_active, is_being_hauled,
  datediff(hour, current_timestamp::timestamp, ast.out_of_lock_timestamp::timestamp) as out_of_lock_hrs,
  case when ast.unplugged = true then 'Yes' end as unplugged,
  case when ast.engine_active = false and (ast.last_checkin_timestamp < current_timestamp - interval '24 hours') then 'Engine Off: 24+ hrs since last message'
       when ast.engine_active = true and (ast.last_checkin_timestamp < current_timestamp - interval '14 hours') then 'Engine On: 14+ hrs since last message'
       when ast.engine_active = false and ast.is_being_hauled = true and (ast.last_checkin_timestamp < current_timestamp - interval '20 minutes') then 'Engine Off/Hauled: 20+ mins since last message'
       when ast.location is null then 'No location data' end as out_of_lock_reason, tt.name as tracker_type
from ES_WAREHOUSE.public.asset_statuses ast join ES_WAREHOUSE.public.assets a on ast.asset_id = a.asset_id
  join ES_WAREHOUSE.public.trackers t on a.tracker_id = t.tracker_id
left join analytics.public.MARKET_REGION_XWALK as x on  coalesce(a.RENTAL_BRANCH_ID,a.INVENTORY_BRANCH_ID) = x.market_id
left join ES_WAREHOUSE.PUBLIC.TRACKER_TYPES as tt on t.tracker_type_id = tt.tracker_type_id
--from public.tracker_types tt join trackers t on t.tracker_id = tt.tracker_type_id
--from public.asset_statuses_scd_battery_voltage bv join mv_asset_statuses ast on ast.asset_id=bv.asset_id
where ast.asset_id in(select asset_id from ES_WAREHOUSE.public.assets where company_id = 1854)
  and (
      (ast.engine_active = false and (ast.last_checkin_timestamp < current_timestamp - interval '24 hours'))
  or (ast.engine_active = true and (ast.last_checkin_timestamp < current_timestamp - interval '14 hours'))
  or (ast.engine_active = false and ast.is_being_hauled = true and (ast.last_checkin_timestamp < current_timestamp - interval '14 hours'))
  or (ast.location is null)
  )
order by 3 desc)
, tracker_types as(
select tt.tracker_type_id, tt.name
from ES_WAREHOUSE.public.tracker_types tt
)
select st_x(asset_summary.jobsite), st_y(asset_summary.jobsite), * from asset_summary
join tracker_types ttf on final_tracker_type_id=ttf.tracker_type_id
                         ;;
  }

  dimension: final_asset_id {
    primary_key: yes
    type: number
    sql: ${TABLE}.final_asset_id ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}.company_id  ;;
  }

  dimension: last_checkin {
    type: date_time
    sql: ${TABLE}.last_checkin ;;
  }

  dimension: battery_voltage {
    type: number
    sql: ${TABLE}.battery_voltage ;;
  }

  dimension: rssi {
    type: number
    sql: ${TABLE}.rssi  ;;
  }

  dimension: tracker_id {
    type: number
    sql: ${TABLE}.tracker_id ;;
  }

  dimension: final_tracker_type_id {
    type: number
    sql: ${TABLE}.final_tracker_type_id ;;
  }

  dimension: out_of_lock_hrs {
    type: number
    sql: -${TABLE}.out_of_lock_hrs ;;
  }

  dimension:unplugged {
    type: string
    sql: ${TABLE}.unplugged ;;
  }

  dimension:market_id {
    type: number
    sql: ${TABLE}.market_id ;;
  }

  dimension: region {
    type: string
    sql: ${TABLE}.region ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}.district ;;
  }
  dimension: make {
    type: string
    sql: ${TABLE}.make ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}.model ;;
  }

  dimension: tracker_type {
    type: string
    sql: ${TABLE}.tracker_type ;;
  }

  dimension: inventory_branch {
    type: string
    sql: ${TABLE}.inventory_branch ;;
  }



  dimension: out_of_lock_reason {
    type: string
    sql: ${TABLE}.out_of_lock_reason ;;
  }

  dimension: tracker_type_id {
    type: number
    sql: ${TABLE}.tracker_type_id ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}.name ;;
  }

  dimension: hours_filter {
    type: string
    sql: case when  ${out_of_lock_hrs} < 24 then 'a) Less than 1 Day'
        when  ${out_of_lock_hrs} between 24 and 72 then 'b) 1 to 3 Days'
        when  ${out_of_lock_hrs} between 73 and 168 then 'c) 3 to 7 Days'
         when  ${out_of_lock_hrs} between 169 and 336 then 'd) 7 to 14 Days'
         when  ${out_of_lock_hrs} > 336 then 'e) 14 Days+'
        else 'f) N/A' end;;
  }

  }
