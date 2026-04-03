view: used_equipment_sales_price_exceptions {
  sql_table_name: "GS"."USED_EQUIPMENT_SALES_PRICE_EXCEPTIONS"
    ;;

  dimension_group: _fivetran_synced {
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
    sql: CAST(${TABLE}."_FIVETRAN_SYNCED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: _row {
    type: number
    sql: ${TABLE}."_ROW" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: looker_price {
    type: number
    sql: ${TABLE}."LOOKER_PRICE" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
