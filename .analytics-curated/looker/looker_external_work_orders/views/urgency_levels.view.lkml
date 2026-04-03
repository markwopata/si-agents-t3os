view: urgency_levels {
  sql_table_name: "WORK_ORDERS"."URGENCY_LEVELS"
    ;;
  drill_fields: [urgency_level_id]

  dimension: urgency_level_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."URGENCY_LEVEL_ID" ;;
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
    label: "Priority"
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: priority_rank {
    type: string
    sql: case when ${name} = 'Low' then 1
    when ${name} = 'Medium' then 2
    when ${name} = 'High' then 3
    when ${name} = 'Critical' then 4
    else 5
    end;;
  }

  measure: count {
    type: count
    drill_fields: [urgency_level_id, name]
  }
}
