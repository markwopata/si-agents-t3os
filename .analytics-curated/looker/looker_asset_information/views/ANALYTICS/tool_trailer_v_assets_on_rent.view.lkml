view: tool_trailer_v_assets_on_rent {
  sql_table_name: "TOOLS_TRAILER"."V_ASSETS_ON_RENT"
    ;;

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: branch_id {
    type: number
    sql: ${TABLE}."BRANCH_ID" ;;
  }

  dimension: class {
    type: string
    sql: ${TABLE}."CLASS" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: equipment_class_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
  }

  dimension_group: start {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."START_DATE" ;;
  }

 measure: count_assets {
   type: count_distinct
  sql: ${TABLE}."ASSET_ID";;
  drill_fields: [drill_detail*]
 }

  set: drill_detail {
    fields: [asset_id, equipment_class_id, class, company_id, company_name, branch_id, start_date]
  }

}
