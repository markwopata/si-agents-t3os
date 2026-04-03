view: source {
  sql_table_name: "GREENHOUSE"."SOURCE"
    ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ID" ;;
  }

  dimension: _fivetran_deleted {
    type: yesno
    sql: ${TABLE}."_FIVETRAN_DELETED" ;;
  }

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

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: source_type_id {
    type: number
    sql: ${TABLE}."SOURCE_TYPE_ID" ;;
  }

  dimension: source_type_name {
    type: string
    sql: ${TABLE}."SOURCE_TYPE_NAME" ;;
  }

  measure: count {
    type: count
    drill_fields: [id, name, source_type_name]
  }
}
