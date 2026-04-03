view: all_greensill {
  sql_table_name: "DEBT"."ALL_GREENSILL"
    ;;

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: greensill_asset {
    type: string
    sql: ${TABLE}."GREENSILL_ASSET" ;;
  }
  dimension: paid_off {
    type: string
    sql: ${TABLE}."PAID_OFF" ;;
  }


  dimension_group: purchase_created {
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
    sql: ${TABLE}."PURCHASE_CREATED_DATE" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
