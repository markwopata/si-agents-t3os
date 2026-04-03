
view: current_previous_month_oec {
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
             'Current' as timeframe,
             xw.district,
             xw.region_name as region
      from analytics.bi_ops.asset_status_and_rsp_daily_snapshot sc
      left join ANALYTICS.ASSET_DETAILS.ASSET_PHYSICAL ap on sc.ASSET_ID = ap.ASSET_ID
      left join analytics.public.market_region_xwalk xw on sc.rental_branch_id = xw.market_id
      where GENERATED_DAY = CONVERT_TIMEZONE('America/Chicago', current_date)::date
            and ap.OEC is not null
            and xw.MARKET_NAME is not null

      UNION ALL

      select GENERATED_DAY,
             sc.ASSET_ID,
             sc.ASSET_INVENTORY_STATUS, --- Asset's inventory status at that point in time
             concat(ap.MAKE,' ',ap.MODEL) as asset_make_model,
             ap.SERIAL_NUMBER,
             ap.EQUIP_CLASS_NAME,
             ap.OEC,
             sc.RENTAL_BRANCH_ID,
             xw.MARKET_NAME,
             'Previous' as timeframe,
             xw.district,
             xw.region_name as region
      from analytics.bi_ops.asset_status_and_rsp_daily_snapshot sc
      left join ANALYTICS.ASSET_DETAILS.ASSET_PHYSICAL ap on sc.ASSET_ID = ap.ASSET_ID
      left join analytics.public.market_region_xwalk xw on sc.rental_branch_id = xw.market_id
      where GENERATED_DAY = last_day(DATEADD(month,-1,CONVERT_TIMEZONE('America/Chicago', current_date)))::date
            and ap.OEC is not null
            and xw.MARKET_NAME is not null ;;
  }

  measure: count {
    type: count
  }

  dimension: asset_id {
    type: string
    sql: ${TABLE}."ASSET_ID" ;;
    html: <font color="#0063f3 "><u><a href="https://equipmentshare.looker.com/dashboards/169?Asset+ID={{asset_id}}" target="_blank">{{ asset_id._value }}</a></font></u> ;;
  }

  dimension: month {
    type: date
    sql: ${TABLE}."MONTH" ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."RENTAL_BRANCH_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: oec {
    type: number
    sql: ${TABLE}."OEC" ;;
  }

  dimension: timeframe {
    type: string
    sql: ${TABLE}."TIMEFRAME" ;;
  }

  dimension: asset_inventory_status {
    type: string
    sql: ${TABLE}."ASSET_INVENTORY_STATUS" ;;
  }

  dimension: make_and_model {
    type: string
    sql: ${TABLE}."ASSET_MAKE_MODEL" ;;
  }

  dimension: serial_number {
    type: string
    sql: ${TABLE}."SERIAL_NUMBER" ;;
  }

  dimension: equipment_class {
    type: string
    sql: ${TABLE}."EQUIP_CLASS_NAME" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: region {
    type: string
    sql: ${TABLE}."REGION" ;;
  }

  measure: oec_measure {
    label: "OEC"
    type: sum
    sql: ${oec} ;;
    value_format_name: usd_0
  }

  measure: current_month_oec {
    type: sum
    sql: ${oec} ;;
    filters: [timeframe: "Current"]
    drill_fields: [asset_id, make_and_model, equipment_class, serial_number, asset_inventory_status, oec_measure]
    value_format_name: usd_0
  }

  measure: last_month_oec {
    type: sum
    sql: ${oec} ;;
    filters: [timeframe: "Previous"]
    drill_fields: [asset_id, make_and_model, equipment_class, serial_number, asset_inventory_status, oec_measure]
    value_format_name: usd_0
  }
}
