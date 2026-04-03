view: asset_status_key_values_hours {
  derived_table: {
    sql: select * from ES_WAREHOUSE.PUBLIC.ASSET_STATUS_KEY_VALUES where name = 'hours'
      ;;
  }


  dimension: asset_status_key_value_id {
    type: number
    sql: ${TABLE}."ASSET_STATUS_KEY_VALUE_ID" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: asset_status_value_type_id {
    type: number
    sql: ${TABLE}."ASSET_STATUS_VALUE_TYPE_ID" ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: value {
    type: number
    label: "Asset Hours"
    sql: ${TABLE}."VALUE" ;;
    value_format_name: decimal_1
  }


  dimension_group: value_timestamp {
    type: time
    sql: ${TABLE}."VALUE_TIMESTAMP" ;;
  }

  dimension_group: updated {
    type: time
    sql: ${TABLE}."UPDATED" ;;
  }

  dimension_group: _es_update_timestamp {
    type: time
    sql: ${TABLE}."_ES_UPDATE_TIMESTAMP" ;;
  }
  }
