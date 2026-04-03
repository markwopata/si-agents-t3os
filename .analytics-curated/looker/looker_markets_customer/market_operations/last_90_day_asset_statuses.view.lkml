
view: last_90_day_asset_statuses {
  derived_table: {
    sql: select GENERATED_DAY,
             sc.ASSET_ID,
             sc.ASSET_INVENTORY_STATUS, --- Asset's inventory status at that point in time
             concat(ap.MAKE,' ',ap.MODEL) as asset_make_model,
             ap.SERIAL_NUMBER,
             ap.EQUIP_CLASS_NAME,
             ap.OEC,
             sc.RENTAL_BRANCH_ID,
             xw.MARKET_NAME,
             xw.district,
             xw.region_name as region,
             case when sc.ASSET_INVENTORY_STATUS = 'Assigned' then 'Assigned'
                  when sc.ASSET_INVENTORY_STATUS = 'Ready To Rent'
                       OR sc.ASSET_INVENTORY_STATUS = 'Pre-Delivered'
                          then 'Available'
                  when sc.ASSET_INVENTORY_STATUS = 'Pending Return'
                       OR sc.ASSET_INVENTORY_STATUS = 'Pending Return'
                       OR sc.ASSET_INVENTORY_STATUS = 'Make Ready'
                       OR sc.ASSET_INVENTORY_STATUS = 'Needs Inspection'
                       OR sc.ASSET_INVENTORY_STATUS = 'Soft Down'
                       OR sc.ASSET_INVENTORY_STATUS = 'Hard Down'
                          then 'Unavailable'
                  when sc.ASSET_INVENTORY_STATUS = 'On Rent'
                          then 'On Rent'
                       end as asset_inventory_status_breakdown,
                   case when GENERATED_DAY = current_date then 1 else 0 end as current_day_flag
            from analytics.bi_ops.asset_status_and_rsp_daily_snapshot sc
            left join ANALYTICS.ASSET_DETAILS.ASSET_PHYSICAL ap on sc.ASSET_ID = ap.ASSET_ID
            left join analytics.public.market_region_xwalk xw on sc.rental_branch_id = xw.market_id
            where ap.OEC is not null
                  and xw.MARKET_NAME is not null
                  and GENERATED_DAY >= DATEADD(day,-90,current_date) ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension_group: generated {
    type: time
    sql: ${TABLE}."GENERATED_DAY" ;;
  }

  dimension: asset_id {
    type: string
    sql: ${TABLE}."ASSET_ID" ;;
    primary_key: yes
  }

  dimension: asset_inventory_status {
    type: string
    sql: ${TABLE}."ASSET_INVENTORY_STATUS" ;;
  }

  dimension: asset_make_model {
    type: string
    sql: ${TABLE}."ASSET_MAKE_MODEL" ;;
  }

  dimension: serial_number {
    type: string
    sql: ${TABLE}."SERIAL_NUMBER" ;;
  }

  dimension: equip_class_name {
    type: string
    sql: ${TABLE}."EQUIP_CLASS_NAME" ;;
  }

  dimension: oec {
    type: number
    sql: ${TABLE}."OEC" ;;
  }

  dimension: rental_branch_id {
    type: string
    sql: ${TABLE}."RENTAL_BRANCH_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: region {
    type: string
    sql: ${TABLE}."REGION" ;;
  }

  dimension: asset_inventory_status_breakdown {
    type: string
    sql: ${TABLE}."ASSET_INVENTORY_STATUS_BREAKDOWN" ;;
  }

  dimension: current_day_flag {
    type: number
    sql: ${TABLE}."CURRENT_DAY_FLAG" ;;
  }

  measure: total_assigned_oec {
    type: sum
    sql: ${oec} ;;
    filters: [asset_inventory_status_breakdown: "Assigned"]
    value_format_name: usd_0
    drill_fields: [detail*]
  }

  measure: total_available_oec {
    type: sum
    sql: ${oec} ;;
    filters: [asset_inventory_status_breakdown: "Available"]
    value_format_name: usd_0
    drill_fields: [detail*]
  }

  measure: total_unavailable_oec {
    type: sum
    sql: ${oec} ;;
    filters: [asset_inventory_status_breakdown: "Unavailable"]
    value_format_name: usd_0
    drill_fields: [detail*]
  }

  measure: total_on_rent_oec {
    type: sum
    sql: ${oec} ;;
    filters: [asset_inventory_status_breakdown: "On Rent"]
    value_format_name: usd_0
    drill_fields: [detail*]
  }

  measure: total_count_of_assigned_assets {
    type: count_distinct
    filters: [asset_inventory_status_breakdown: "Assigned"]
    drill_fields: [detail*]
  }

  measure: total_count_of_available_assets {
    type: count_distinct
    filters: [asset_inventory_status_breakdown: "Available"]
    drill_fields: [detail*]
  }

  measure: total_count_of_unavailable_assets {
    type: count_distinct
    filters: [asset_inventory_status_breakdown: "Unavailable"]
    drill_fields: [detail*]
  }

  measure: total_count_of_on_rent_assets {
    type: count_distinct
    filters: [asset_inventory_status_breakdown: "On Rent"]
    drill_fields: [detail*]
  }

  set: detail {
    fields: [
  generated_date,
  asset_id,
  asset_inventory_status,
  asset_make_model,
  serial_number,
  equip_class_name,
  oec,
  rental_branch_id,
  market_name,
  district,
  region,
  asset_inventory_status_breakdown,
  current_day_flag
    ]
  }
}
