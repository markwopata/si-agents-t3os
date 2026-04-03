view: fulfillment_center_markets {
  sql_table_name: "PARTS_INVENTORY"."FULFILLMENT_CENTER_MARKETS" ;;

  dimension_group: _fivetran_synced {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_FIVETRAN_SYNCED" AS TIMESTAMP_NTZ) ;;
  }
  dimension: _row {
    type: number
    sql: ${TABLE}."_ROW" ;;
  }
  dimension_group: date_added {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}."DATE_ADDED" ;;
  }
  dimension: gm {
    type: string
    sql: ${TABLE}."GM" ;;
  }
  dimension: location {
    primary_key: yes
    type: string
    sql: ${TABLE}."LOCATION" ;;
  }
  dimension: notes {
    type: string
    sql: ${TABLE}."NOTES" ;;
  }
  dimension: pm {
    type: string
    sql: ${TABLE}."PM" ;;
  }
  dimension: poc {
    type: string
    sql: ${TABLE}."POC" ;;
  }
  dimension: sm {
    type: string
    sql: ${TABLE}."SM" ;;
  }
  measure: count {
    type: count
  }
}
