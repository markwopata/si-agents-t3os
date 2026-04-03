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
    # hidden: yes
    sql: ${TABLE}."COMPANY_DIVISION_ID" ;;
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

  measure: count {
    type: count
    drill_fields: [equipment_class_id, name, company_divisions.company_division_id, company_divisions.name]
  }
}
