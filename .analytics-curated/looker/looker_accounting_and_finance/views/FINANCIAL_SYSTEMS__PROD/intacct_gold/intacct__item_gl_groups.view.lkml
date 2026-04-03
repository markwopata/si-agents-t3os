view: intacct__item_gl_groups {
  sql_table_name: "INTACCT_GOLD"."INTACCT__ITEM_GL_GROUPS" ;;

  dimension: pk_item_gl_group_id {
    type: number
    primary_key: yes
    sql: ${TABLE}."PK_ITEM_GL_GROUP_ID" ;;
    value_format_name: id
  }

  dimension: name_gl_item_group {
    type: string
    sql: ${TABLE}."NAME_GL_ITEM_GROUP" ;;
  }

  dimension: number_gl_account {
    type: string
    sql: ${TABLE}."NUMBER_GL_ACCOUNT" ;;
  }

  dimension: name_gl_account {
    type: string
    sql: ${TABLE}."NAME_GL_ACCOUNT" ;;
  }

  dimension: number_oe_account {
    type: string
    sql: ${TABLE}."NUMBER_OE_ACCOUNT" ;;
  }

  dimension: name_oe_account {
    type: string
    sql: ${TABLE}."NAME_OE_ACCOUNT" ;;
  }

  dimension: number_po_account {
    type: string
    sql: ${TABLE}."NUMBER_PO_ACCOUNT" ;;
  }

  dimension: name_po_account {
    type: string
    sql: ${TABLE}."NAME_PO_ACCOUNT" ;;
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

  dimension: fk_offset_oe_gl_account_id {
    type: number
    sql: ${TABLE}."FK_OFFSET_OE_GL_ACCOUNT_ID" ;;
    value_format_name: id
  }

  dimension: fk_offset_po_gl_account_id {
    type: number
    sql: ${TABLE}."FK_OFFSET_PO_GL_ACCOUNT_ID" ;;
    value_format_name: id
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
