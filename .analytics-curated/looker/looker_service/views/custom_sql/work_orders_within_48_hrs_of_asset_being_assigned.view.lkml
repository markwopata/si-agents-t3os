view: work_orders_within_48_hrs_of_asset_being_assigned {
  derived_table: {
    # datagroup_trigger: Every_Two_Hours_Update
#     indexes: ["work_order_id","market_name"]
    sql: with assets_assigned as (
    select
    sais.asset_id,
    sais.date_start,
    sais.asset_inventory_status
    from
    ES_WAREHOUSE.scd.scd_asset_inventory_status sais
    left join ES_WAREHOUSE.PUBLIC.assets a on a.asset_id = sais.asset_id
    where
    a.company_id <> 11606
    and LEFT(a.serial_number, 2) <> 'RR'
    and LEFT(a.custom_name, 2) <> 'RR'
    and sais.asset_inventory_status = 'On Rent'
    ),
    work_order_time as (
    select
    work_order_id,
    asset_id,
    convert_timezone('America/Chicago',date_created) as date_created,
    branch_id
    from
    ES_WAREHOUSE.work_orders.work_orders wo
    where
    work_order_type_id = 1
    and archived_date is null
    )
    select
    aa.asset_id,
    convert_timezone('America/Chicago',aa.date_start) as date_start,
    convert_timezone('America/Chicago',wo.date_created) as date_created,
    wo.work_order_id,
    wo.branch_id as work_order_branch_id,
    case when convert_timezone('America/Chicago',wo.date_created) between convert_timezone('America/Chicago',aa.date_start) and convert_timezone('America/Chicago',aa.date_start) + interval '48 hours' then 1 else 0 end as date_start_within_last_2_days,
    concat(a.make,' ',a.model) as asset_make_and_model,
    a.rental_branch_id as asset_branch_id,
    mrx.market_name,
    --mrx.name as market_name,
    mrx.region_name,
    --mrx.aka as region_name,
    mrx.district
    from
    assets_assigned aa
    inner join work_order_time wo on aa.asset_id = wo.asset_id and convert_timezone('America/Chicago',wo.date_created) between convert_timezone('America/Chicago',aa.date_start) and convert_timezone('America/Chicago',aa.date_start) + interval '48 hours'
    left join ES_WAREHOUSE.public.assets a on a.asset_id = aa.asset_id
    left join ES_WAREHOUSE.public.markets m on m.market_id = a.rental_branch_id
    left join analytics.public.market_region_xwalk mrx on mrx.market_id = wo.branch_id
    where
    a.asset_type_id = 1
    and a.rental_branch_id is not null
    and m.company_id = 1854
    ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension_group: date_start {
    type: time
    sql: ${TABLE}."DATE_START" ;;
  }

  dimension_group: date_created {
    type: time
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension: work_order_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_ID" ;;
  }

  dimension: work_order_branch_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_BRANCH_ID" ;;
  }

  dimension: date_start_within_last_2_days {
    type: number
    sql: ${TABLE}."DATE_START_WITHIN_LAST_2_DAYS" ;;
  }

  dimension: asset_make_and_model {
    type: string
    sql: ${TABLE}."ASSET_MAKE_AND_MODEL" ;;
  }

  dimension: asset_branch_id {
    type: number
    sql: ${TABLE}."ASSET_BRANCH_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: work_order_id_with_link_to_work_order {
    type: string
    sql: ${work_order_id} ;;
    html: <font color="blue "><u><a href="https://app.estrack.com/#/service/work-orders/{{ work_order_id._value }}" target="_blank">{{ work_order_id._value }}</a></font></u> ;;
  }

  set: detail {
    fields: [
      asset_id,
      date_start_time,
      date_created_time,
      work_order_id,
      work_order_branch_id,
      date_start_within_last_2_days,
      asset_make_and_model,
      asset_branch_id,
      market_name,
      region_name,
      district
    ]
  }
}
