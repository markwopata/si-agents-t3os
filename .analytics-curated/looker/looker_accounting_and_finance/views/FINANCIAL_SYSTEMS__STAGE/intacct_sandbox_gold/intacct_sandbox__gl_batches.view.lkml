view: intacct_sandbox__gl_batches {
  sql_table_name: "GOLD"."INTACCT_SANDBOX__GL_BATCHES" ;;

  dimension_group: date_batch {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_BATCH" ;;
  }
  dimension: fk_created_by_user_id {
    type: number
    sql: ${TABLE}."FK_CREATED_BY_USER_ID" ;;
  }
  dimension: fk_extract_hash_id {
    type: number
    sql: ${TABLE}."FK_EXTRACT_HASH_ID" ;;
  }
  dimension: fk_gl_allocation_run_id {
    type: number
    sql: ${TABLE}."FK_GL_ALLOCATION_RUN_ID" ;;
  }
  dimension: fk_mega_entity_id {
    type: number
    sql: ${TABLE}."FK_MEGA_ENTITY_ID" ;;
  }
  dimension: fk_modified_by_user_id {
    type: number
    sql: ${TABLE}."FK_MODIFIED_BY_USER_ID" ;;
  }
  dimension: fk_pr_batch_id {
    type: number
    sql: ${TABLE}."FK_PR_BATCH_ID" ;;
  }
  dimension: fk_reversed_id {
    type: number
    sql: ${TABLE}."FK_REVERSED_ID" ;;
  }
  dimension: fk_schop_id {
    type: string
    sql: ${TABLE}."FK_SCHOP_ID" ;;
  }
  dimension: fk_sup_doc_id {
    type: number
    sql: ${TABLE}."FK_SUP_DOC_ID" ;;
  }
  dimension: fk_template_id {
    type: number
    sql: ${TABLE}."FK_TEMPLATE_ID" ;;
  }
  dimension: fk_wip_relief_run_id {
    type: string
    sql: ${TABLE}."FK_WIP_RELIEF_RUN_ID" ;;
  }
  dimension: id_mega_entity {
    type: string
    sql: ${TABLE}."ID_MEGA_ENTITY" ;;
  }
  dimension: id_sup_doc {
    type: string
    sql: ${TABLE}."ID_SUP_DOC" ;;
  }
  dimension: implications_tax {
    type: string
    sql: ${TABLE}."IMPLICATIONS_TAX" ;;
  }
  dimension: is_statistical {
    type: yesno
    sql: ${TABLE}."IS_STATISTICAL" ;;
  }
  dimension: journal {
    type: string
    sql: ${TABLE}."JOURNAL" ;;
  }
  dimension: module_source {
    type: string
    sql: ${TABLE}."MODULE_SOURCE" ;;
  }
  dimension: name_file {
    type: string
    sql: ${TABLE}."NAME_FILE" ;;
  }
  dimension: name_mega_entity {
    type: string
    sql: ${TABLE}."NAME_MEGA_ENTITY" ;;
  }
  dimension: number_batch {
    type: number
    sql: ${TABLE}."NUMBER_BATCH" ;;
  }
  dimension: number_journal_sequence {
    type: string
    sql: ${TABLE}."NUMBER_JOURNAL_SEQUENCE" ;;
  }
  dimension: number_reference {
    type: string
    sql: ${TABLE}."NUMBER_REFERENCE" ;;
  }
  dimension: pk_gl_batch_id {
    type: number
    sql: ${TABLE}."PK_GL_BATCH_ID" ;;
  }
  dimension: reversed_from {
    type: string
    sql: ${TABLE}."REVERSED_FROM" ;;
  }
  dimension: state_batch {
    type: string
    sql: ${TABLE}."STATE_BATCH" ;;
  }
  dimension: status_reversed {
    type: string
    sql: ${TABLE}."STATUS_REVERSED" ;;
  }
  dimension_group: timestamp_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_CREATED" ;;
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
  dimension_group: timestamp_modified {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_MODIFIED" ;;
  }
  dimension: title_batch {
    type: string
    sql: ${TABLE}."TITLE_BATCH" ;;
  }
  measure: count {
    type: count
  }
}
