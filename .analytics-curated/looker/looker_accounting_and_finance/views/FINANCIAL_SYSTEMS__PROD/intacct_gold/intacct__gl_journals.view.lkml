view: intacct__gl_journals {
  sql_table_name: "INTACCT_GOLD"."INTACCT__GL_JOURNALS" ;;

  dimension: pk_gl_journal_id {
    type: number
    primary_key: yes
    sql: ${TABLE}."PK_GL_JOURNAL_ID" ;;
    value_format_name: id
  }

  dimension: symbol_journal {
    type: string
    sql: ${TABLE}."SYMBOL_JOURNAL" ;;
  }

  dimension: name_journal {
    type: string
    sql: ${TABLE}."NAME_JOURNAL" ;;
  }

  dimension: id_book {
    type: string
    sql: ${TABLE}."ID_BOOK" ;;
  }

  dimension: status_journal {
    type: string
    sql: ${TABLE}."STATUS_JOURNAL" ;;
  }

  dimension: is_adjustment_allowed {
    type: yesno
    sql: ${TABLE}."IS_ADJUSTMENT_ALLOWED" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_billable {
    type: yesno
    sql: ${TABLE}."IS_BILLABLE" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
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

  dimension_group: date_start {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_START" ;;
  }

  dimension_group: date_last {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_LAST" ;;
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
