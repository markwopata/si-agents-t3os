view: dim_equipment_classes {
  sql_table_name: "BUSINESS_INTELLIGENCE"."GOLD"."V_DIM_EQUIPMENT_CLASSES" ;;

  dimension_group: _created_recordtimestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."_CREATED_RECORDTIMESTAMP" ;;
    hidden: yes
  }

  dimension_group: _updated_recordtimestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."_UPDATED_RECORDTIMESTAMP" ;;
    hidden: yes
  }

  dimension: business_segment_name {
    type: string
    sql: ${TABLE}."BUSINESS_SEGMENT_NAME" ;;
  }

  dimension: category_description {
    type: string
    sql: ${TABLE}."CATEGORY_DESCRIPTION" ;;
  }

  dimension: category_id {
    type: number
    sql: ${TABLE}."CATEGORY_ID" ;;
  }

  dimension: category_is_active {
    type: yesno
    sql: ${TABLE}."CATEGORY_IS_ACTIVE" ;;
  }

  dimension: category_name {
    type: string
    sql: ${TABLE}."CATEGORY_NAME" ;;
  }

  dimension: company_division_id {
    type: number
    sql: ${TABLE}."COMPANY_DIVISION_ID" ;;
  }

  dimension: company_division_name {
    type: string
    sql: ${TABLE}."COMPANY_DIVISION_NAME" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: equipment_class_description {
    type: string
    sql: ${TABLE}."EQUIPMENT_CLASS_DESCRIPTION" ;;
  }

  dimension: equipment_class_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
  }

  dimension: equipment_class_key {
    type: string
    sql: ${TABLE}."EQUIPMENT_CLASS_KEY" ;;
    primary_key: yes
    hidden: yes
  }

  dimension: equipment_class_name {
    type: string
    sql: ${TABLE}."EQUIPMENT_CLASS_NAME" ;;
  }

  dimension: grandparent_category_name {
    type: string
    sql: ${TABLE}."GRANDPARENT_CATEGORY_NAME" ;;
  }

  dimension: is_deleted {
    type: yesno
    sql: ${TABLE}."IS_DELETED" ;;
  }

  dimension: is_rentable {
    type: yesno
    sql: ${TABLE}."IS_RENTABLE" ;;
  }

  dimension: parent_category_name {
    type: string
    sql: ${TABLE}."PARENT_CATEGORY_NAME" ;;
  }

  measure: count {
    type: count
  }

}
