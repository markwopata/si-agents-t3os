view: rejection_reason {
  sql_table_name: "GREENHOUSE"."REJECTION_REASON"
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

  dimension: reason {
    type: string
    sql: ${TABLE}."REASON" ;;
  }

  dimension: rejection_reason_type_id {
    type: number
    sql: ${TABLE}."REJECTION_REASON_TYPE_ID" ;;
  }

  dimension: rejection_reason_type_name {
    type: string
    sql: ${TABLE}."REJECTION_REASON_TYPE_NAME" ;;
  }

  measure: count {
    type: count
    drill_fields: [id, rejection_reason_type_name]
  }
}
