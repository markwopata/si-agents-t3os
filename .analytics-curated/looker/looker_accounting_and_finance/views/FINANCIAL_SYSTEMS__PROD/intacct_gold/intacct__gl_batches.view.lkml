view: intacct__gl_batches {
  sql_table_name: "INTACCT_GOLD"."INTACCT__GL_BATCHES" ;;

  dimension: pk_gl_batch_id {
    type: number
    primary_key: yes
    sql: ${TABLE}."PK_GL_BATCH_ID" ;;
    value_format_name: id
  }

  dimension_group: date_batch {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_BATCH" ;;
  }

  dimension_group: date_reversed {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_REVERSED" ;;
  }

  dimension_group: date_reversed_from {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_REVERSED_FROM" ;;
  }

  dimension: number_batch {
    type: number
    sql: ${TABLE}."NUMBER_BATCH" ;;
    value_format_name: id
  }

  dimension: title_batch {
    type: string
    sql: ${TABLE}."TITLE_BATCH" ;;
  }

  dimension: module {
    type: string
    sql: ${TABLE}."MODULE" ;;
  }

  dimension: journal {
    type: string
    sql: ${TABLE}."JOURNAL" ;;
  }

  dimension: number_journal_sequence {
    type: string
    sql: ${TABLE}."NUMBER_JOURNAL_SEQUENCE" ;;
  }

  dimension: state_batch {
    type: string
    sql: ${TABLE}."STATE_BATCH" ;;
  }

  dimension: reference {
    type: string
    sql: ${TABLE}."REFERENCE" ;;
  }

  dimension: implications_tax {
    type: string
    sql: ${TABLE}."IMPLICATIONS_TAX" ;;
  }

  dimension: id_mega_entity {
    type: string
    sql: ${TABLE}."ID_MEGA_ENTITY" ;;
  }

  dimension: name_location {
    type: string
    sql: ${TABLE}."NAME_LOCATION" ;;
  }

  dimension: name_created_by_user {
    type: string
    sql: ${TABLE}."NAME_CREATED_BY_USER" ;;
  }

  dimension: name_modified_by_user {
    type: string
    sql: ${TABLE}."NAME_MODIFIED_BY_USER" ;;
  }

  dimension: fk_created_by_user_id {
    type: number
    sql: ${TABLE}."FK_CREATED_BY_USER_ID" ;;
    value_format_name: id
  }

  dimension: fk_modified_by_user_id {
    type: number
    sql: ${TABLE}."FK_MODIFIED_BY_USER_ID" ;;
    value_format_name: id
  }

  dimension: fk_pr_batch_id {
    type: number
    sql: ${TABLE}."FK_PR_BATCH_ID" ;;
    value_format_name: id
  }

  dimension: fk_reversed_id {
    type: number
    sql: ${TABLE}."FK_REVERSED_ID" ;;
    value_format_name: id
  }

  dimension: fk_schop_id {
    type: number
    sql: ${TABLE}."FK_SCHOP_ID" ;;
    value_format_name: id
  }

  dimension: fk_template_id {
    type: number
    sql: ${TABLE}."FK_TEMPLATE_ID" ;;
    value_format_name: id
  }

  dimension: fk_mega_entity_id {
    type: number
    sql: ${TABLE}."FK_MEGA_ENTITY_ID" ;;
    value_format_name: id
  }

  dimension: url_intacct {
    type: string
    sql: ${TABLE}."URL_INTACCT" ;;
    link: {
      label: "URL Intacct"
      url: "{{ value }}"
    }
  }

  dimension_group: timestamp_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_CREATED" ;;
  }

  dimension_group: timestamp_modified {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_MODIFIED" ;;
  }

  dimension_group: timestamp_dds_loaded {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_DDS_LOADED" ;;
  }

  dimension_group: timestamp_loaded {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_LOADED" ;;
  }

  measure: count {
    type: count
  }
}
