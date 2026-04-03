view: asset_status_key_values {
  derived_table: {
    sql: select * from ES_WAREHOUSE.PUBLIC.ASSET_STATUS_KEY_VALUES where name = 'asset_inventory_status'
      ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
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
    type: string
    label: "Asset Inventory Status"
    sql: ${TABLE}."VALUE" ;;
    drill_fields: [asset_id]
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

  measure: number_of_statuses {
    type: count
    drill_fields: [asset_id,value,markets.name,assets_inventory.make,equipment_models.name,equipment_classes.name]
  }

  measure: Total_unavailable_assets {
    type: count
    filters: {
      field: value
      value: "Pending Return,Make Ready,Needs Inspection, Soft Down, Hard Down"
    }
  }

  set: detail {
    fields: [
      asset_status_key_value_id,
      asset_id,
      asset_status_value_type_id,
      name,
      value,
      value_timestamp_time,
      updated_time,
      _es_update_timestamp_time
    ]
  }
}
