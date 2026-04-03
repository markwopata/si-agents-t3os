view: part_substitutes {
  sql_table_name: "ANALYTICS"."PARTS_INVENTORY"."PART_SUBSTITUTES" ;;
  drill_fields: [part_substitute_id]

  dimension: part_substitute_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."PART_SUBSTITUTE_ID" ;;
  }
  dimension_group: created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."CREATED_DATE" ;;
  }
  dimension: isactive {
    type: yesno
    sql: ${TABLE}."ISACTIVE" ;;
  }
  dimension: notes {
    type: string
    sql: ${TABLE}."NOTES" ;;
  }
  dimension: part_family_id {
    type: number
    sql: ${TABLE}."PART_FAMILY_ID" ;;
  }
  dimension: part_id {
    type: number
    sql: ${TABLE}."PART_ID" ;;
  }
  dimension: part_number {
    type: string
    sql: ${TABLE}."PART_NUMBER" ;;
  }
  dimension: provider_id {
    type: number
    sql: ${TABLE}."PROVIDER_ID" ;;
  }
  dimension: provider_name {
    type: string
    sql: ${TABLE}."PROVIDER_NAME" ;;
  }
  dimension: sub_part_id {
    type: number
    sql: ${TABLE}."SUB_PART_ID" ;;
  }
  dimension: sub_part_number {
    type: string
    sql: ${TABLE}."SUB_PART_NUMBER" ;;
  }
  dimension: sub_provider_id {
    type: number
    sql: ${TABLE}."SUB_PROVIDER_ID" ;;
  }
  dimension: sub_provider_name {
    type: string
    sql: ${TABLE}."SUB_PROVIDER_NAME" ;;
  }
  dimension: substitution_type {
    type: string
    sql: ${TABLE}."SUBSTITUTION_TYPE" ;;
  }
  dimension_group: updated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."UPDATED_DATE" ;;
  }
  dimension: updated_email {
    type: string
    sql: ${TABLE}."UPDATED_EMAIL" ;;
  }
  dimension: updated_user_id {
    type: number
    sql: ${TABLE}."UPDATED_USER_ID" ;;
  }
  measure: count {
    type: count
    drill_fields: [part_substitute_id, provider_name, sub_provider_name]
  }
}

view: part_substitutes_flag_sub_type {
  derived_table: {
    sql:
      select part_id
           , listagg(distinct concat(substitution_type||'-'||isactive), ', ') as sub_type_list
      from ${part_substitutes.SQL_TABLE_NAME} AS part_substitutes
      group by part_id
      ;;
  }

  dimension: part_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."PART_ID" ;;
  }

  dimension: sub_type_list {
    type: string
    sql: ${TABLE}."SUB_TYPE_LIST" ;;
  }

  dimension: has_reman_sub {
    type: yesno
    sql: ${TABLE}."SUB_TYPE_LIST" ilike '%REMAN-true%' ;;
  }

  dimension: has_aftermarket_sub {
    type: yesno
    sql: ${TABLE}."SUB_TYPE_LIST" ilike '%Aftermarket Vendor-true%' ;;
  }
}
