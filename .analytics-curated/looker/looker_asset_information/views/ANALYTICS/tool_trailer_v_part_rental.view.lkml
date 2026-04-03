view: tool_trailer_v_part_rental {
  sql_table_name: "TOOLS_TRAILER"."V_PART_RENTAL"
    ;;

  dimension: check_out_user {
    type: string
    sql: ${TABLE}."CHECK_OUT_USER" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: created_by_user_in {
    type: string
    sql: ${TABLE}."CREATED_BY_USER_IN" ;;
  }

  dimension: created_by_user_out {
    type: string
    sql: ${TABLE}."CREATED_BY_USER_OUT" ;;
  }

  dimension_group: date_updated_in {
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
    sql: CAST(${TABLE}."DATE_UPDATED_IN" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: date_updated_out {
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
    sql: CAST(${TABLE}."DATE_UPDATED_OUT" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: end {
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
    sql: CAST(${TABLE}."END_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: modificed_by_user_in {
    type: string
    sql: ${TABLE}."MODIFICED_BY_USER_IN" ;;
  }

  dimension: modified_by_user_out {
    type: string
    sql: ${TABLE}."MODIFIED_BY_USER_OUT" ;;
  }

  dimension: no_out_rental {
    type: yesno
    sql: ${TABLE}."NO_OUT_RENTAL" ;;
  }

  dimension: note_in {
    type: string
    sql: ${TABLE}."NOTE_IN" ;;
  }

  dimension: note_out {
    type: string
    sql: ${TABLE}."NOTE_OUT" ;;
  }

  dimension: on_rent {
    type: yesno
    sql: ${TABLE}."ON_RENT" ;;
  }

  dimension: part_id {
    type: number
    sql: ${TABLE}."PART_ID" ;;
  }

  dimension: part_number {
    type: string
    sql: ${TABLE}."PART_NUMBER" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: pk_key {
    type: number
    primary_key: yes
    sql: ${TABLE}."PK_KEY" ;;
  }

  dimension_group: start {
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
    sql: CAST(${TABLE}."START_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: tool_trailer_part_rental_id_in {
    type: number
    value_format_name: id
    sql: ${TABLE}."TOOL_TRAILER_PART_RENTAL_ID_IN" ;;
  }

  dimension: tool_trailer_part_rental_id_out {
    type: number
    value_format_name: id
    sql: ${TABLE}."TOOL_TRAILER_PART_RENTAL_ID_OUT" ;;
  }

  dimension: user_id_in {
    type: number
    value_format_name: id
    sql: ${TABLE}."USER_ID_IN" ;;
  }

  dimension: user_id_out {
    type: number
    value_format_name: id
    sql: ${TABLE}."USER_ID_OUT" ;;
  }

  dimension: branch_id {
    type: number
    sql: ${TABLE}."BRANCH_ID" ;;
  }

  dimension: branch {
    type: string
    sql: ${TABLE}."BRANCH" ;;
  }

  measure: count_assets {
    type: count_distinct
    sql: ${TABLE}."PK_KEY" ;;
    drill_fields: [drill_detail*]
  }

  measure: count {
    type: count
    drill_fields: [company_name]
  }

  set: drill_detail {
    fields: [tool_trailer_part_rental_id_in, tool_trailer_part_rental_id_out, part_id, part_number, company_name, start_date, created_by_user_out, created_by_user_in]
  }
}
