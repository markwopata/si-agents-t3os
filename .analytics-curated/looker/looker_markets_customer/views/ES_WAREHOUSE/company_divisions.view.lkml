view: company_divisions {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."COMPANY_DIVISIONS"
    ;;
  drill_fields: [company_division_id]

  dimension: company_division_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."COMPANY_DIVISION_ID" ;;
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

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  measure: count {
    type: count
    drill_fields: [company_division_id, name, equipment_classes.count]
  }
}
