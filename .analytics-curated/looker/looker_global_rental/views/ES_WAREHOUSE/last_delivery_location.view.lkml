view: last_delivery_location {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."LAST_DELIVERY_LOCATION"
    ;;

  dimension: address {
    label: "Delivery Location"
    type: string
    sql: ${TABLE}."ADDRESS" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: delivery_id {
    primary_key:  yes
    type: number
    sql: ${TABLE}."DELIVERY_ID" ;;
  }

  dimension: drop_off_or_return {
    label: "Drop Off/Return"
    type: string
    sql: ${TABLE}."DROP_OFF_OR_RETURN" ;;
  }

  dimension_group: last_delivery {
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
    sql: CAST(${TABLE}."LAST_DELIVERY" AS TIMESTAMP_NTZ) ;;
  }

  dimension: rental_id {
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
