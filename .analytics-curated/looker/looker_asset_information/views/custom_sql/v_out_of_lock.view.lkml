view: v_out_of_lock {
  derived_table: {
    sql: select AA.ASSET_ID,
       AA.COMPANY_ID,
       AA.OWNER,
       AA.EQUIPMENT_CLASS_ID,
       AA.CLASS,
       AA.CATEGORY_ID,
       AA.CATEGORY,
       AA.YEAR,
       AA.MAKE,
       AA.MODEL,
       AA.SERIAL_NUMBER,
       AA.VIN,
       AA.RENTAL_BRANCH_ID,
       VOOL.OUT_OF_LOCK_TIMESTAMP,
       VOOL.HOURS_OUT_OF_LOCK,
       VOOL.OVER_72_HOURS_FLAG,
       VOOL.OUT_OF_LOCK_REASON,
       VOOL.UNPLUGGED_FLAG,
       m.NAME as market_name
from ES_WAREHOUSE.PUBLIC.V_OUT_OF_LOCK VOOL
        join ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE AA
              on VOOL.ASSET_ID = AA.ASSET_ID
        left join ES_WAREHOUSE.PUBLIC.MARKETS m
            on m.MARKET_ID = aa.RENTAL_BRANCH_ID
       ;;
  }


  dimension: asset_id {
    type: number
    primary_key: yes
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: owner {
    type: string
    sql: ${TABLE}."OWNER" ;;
  }

  dimension: equipment_class_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
  }

  dimension: class {
    type: string
    sql: ${TABLE}."CLASS" ;;
  }

  dimension: category_id {
    type: number
    sql: ${TABLE}."CATEGORY_ID" ;;
  }

  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }

  dimension: year {
    type: number
    sql: ${TABLE}."YEAR" ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }

  dimension: serial_number {
    type: string
    sql: ${TABLE}."SERIAL_NUMBER" ;;
  }

  dimension: vin {
    type: string
    sql: ${TABLE}."VIN" ;;
  }

  dimension: rental_branch_id {
    type: number
    sql: ${TABLE}."RENTAL_BRANCH_ID" ;;
  }

  dimension: hours_out_of_lock {
    type: number
    sql: ${TABLE}."HOURS_OUT_OF_LOCK" ;;
  }

  dimension: out_of_lock_reason {
    type: string
    sql: ${TABLE}."OUT_OF_LOCK_REASON" ;;
  }

  dimension_group: out_of_lock_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."OUT_OF_LOCK_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: over_72_hours_flag {
    type: yesno
    sql: ${TABLE}."OVER_72_HOURS_FLAG" ;;
  }

  dimension: unplugged_flag {
    type: yesno
    sql: ${TABLE}."UNPLUGGED_FLAG" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  measure: asset_count {
    type: count_distinct
    sql: ${asset_id} ;;
    drill_fields: [asset_id, out_of_lock_reason]
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
