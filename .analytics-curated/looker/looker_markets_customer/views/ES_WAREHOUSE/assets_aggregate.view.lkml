view: assets_aggregate {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."ASSETS_AGGREGATE"
    ;;

  dimension: asset_id {
    type: number
    primary_key: yes
    value_format: "0"
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: asset_type {
    type: string
    sql: ${TABLE}."ASSET_TYPE" ;;
  }

  dimension: asset_type_id {
    type: number
    sql: ${TABLE}."ASSET_TYPE_ID" ;;
  }

  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }

  dimension: class {
    type: string
    sql: ${TABLE}."CLASS" ;;
  }

  dimension: company_id {
    type: number
    value_format: "0"
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: custom_name {
    type: string
    sql: ${TABLE}."CUSTOM_NAME" ;;
  }

  dimension: equipment_class_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
  }

  dimension: make {
    type:  string
    sql:  ${TABLE}."MAKE" ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }

  dimension: oec {
    type: number
    sql: ${TABLE}."OEC" ;;
  }

  dimension: owner {
    type: string
    sql: ${TABLE}."OWNER" ;;
  }

  dimension: serial_number {
    type: string
    sql: ${TABLE}."SERIAL_NUMBER" ;;
  }

  dimension: vin {
    type: string
    sql: ${TABLE}."VIN" ;;
  }

  dimension: year {
    type: number
    sql: ${TABLE}."YEAR" ;;
  }

  dimension: is_rerent {
    type: yesno
    sql: ${company_id} = 11606 or LEFT(${custom_name}, 2) = 'RR' or LEFT(${serial_number}, 2) = 'RR' ;;
  }

  # - - - - - MEASURES - - - - -

  measure: total_oec {
    type: sum
    sql: ${oec} ;;
  }

  measure: count {
    type: count
    drill_fields: [custom_name]
  }
}
