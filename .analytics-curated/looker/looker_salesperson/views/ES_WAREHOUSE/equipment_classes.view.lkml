view: equipment_classes {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."EQUIPMENT_CLASSES"
    ;;
  drill_fields: [equipment_class_id]

  dimension: equipment_class_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
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

  dimension: category_id {
    type: number
    sql: ${TABLE}."CATEGORY_ID" ;;
  }

  dimension: company_division_id {
    type: number
    sql: ${TABLE}."COMPANY_DIVISION_ID" ;;
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

  dimension_group: date_deleted {
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
    sql: CAST(${TABLE}."DATE_DELETED" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: date_updated {
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
    sql: CAST(${TABLE}."DATE_UPDATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: deleted {
    type: yesno
    sql: ${TABLE}."DELETED" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: maintenance_group_id {
    type: number
    sql: ${TABLE}."MAINTENANCE_GROUP_ID" ;;
  }

  dimension: metric_name {
    type: string
    sql: ${TABLE}."METRIC_NAME" ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: primary_photo_id {
    type: number
    sql: ${TABLE}."PRIMARY_PHOTO_ID" ;;
  }

  dimension: rentable {
    type: yesno
    sql: ${TABLE}."RENTABLE" ;;
  }

  dimension: weekly_minimum {
    type: yesno
    sql: ${TABLE}."WEEKLY_MINIMUM" ;;
  }

  dimension: business_segment_id {
    type: number
    sql: ${TABLE}."BUSINESS_SEGMENT_ID" ;;
  }

  dimension: business_segment {
    type: string
    sql: case when ${business_segment_id} = 1 then 'Core'
              when ${business_segment_id} = 2 then 'Advanced Solutions'
              when ${business_segment_id} = 3 then 'ITL'
              else null end;;
  }

  measure: count {
    type: count
    drill_fields: [equipment_class_id, metric_name, name]
  }
}
