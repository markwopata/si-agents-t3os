view: rental_purchase_options {
  sql_table_name: "PUBLIC"."RENTAL_PURCHASE_OPTIONS"
    ;;
  drill_fields: [rental_purchase_option_id]

  dimension: rental_purchase_option_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."RENTAL_PURCHASE_OPTION_ID" ;;
  }

  dimension_group: _es_update_timestamp {
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
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: months {
    type: number
    sql: CASE when ${TABLE}."RENTAL_PURCHASE_OPTION_ID" = 1 then 6
              when ${TABLE}."RENTAL_PURCHASE_OPTION_ID" = 2 then 12
            else null
          end;;
  }

  measure: count {
    type: count
    drill_fields: [rental_purchase_option_id, name]
  }
}
