view: asset_alert_rules {
  sql_table_name: "PUBLIC"."ASSET_ALERT_RULES"
    ;;
  drill_fields: [asset_alert_rule_id]

  dimension: asset_alert_rule_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ASSET_ALERT_RULE_ID" ;;
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

  dimension_group: date_created {
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
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: date_deactivated {
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
    sql: CAST(${TABLE}."DATE_DEACTIVATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: name {
    label: "Alert Rule"
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  measure: count {
    type: count
    drill_fields: [asset_alert_rule_id, name]
  }
}
