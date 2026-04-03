view: greensill_assets_paid_off {
  sql_table_name: "DEBT"."GREENSILL_ASSETS_PAID_OFF"
    ;;

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: greensill {
    type: string
    sql: ${TABLE}."GREENSILL" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
