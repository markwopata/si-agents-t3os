view: asset_types {
  sql_table_name: "PUBLIC"."ASSET_TYPES"
    ;;
  drill_fields: [asset_type_id]

  dimension: asset_type_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ASSET_TYPE_ID" ;;
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

  measure: count {
    type: count
    drill_fields: [asset_type_id, name]
  }

  dimension: asset_type {
    type: string
    sql: concat(upper(substring(${name},1,1)),substring(${name},2,length(${name})))
    ;;
  }

}
