view: intacct__departments {
  sql_table_name: "INTACCT_GOLD"."INTACCT__DEPARTMENTS" ;;

  dimension: pk_department_id {
    type: number
    primary_key: yes
    sql: ${TABLE}."PK_DEPARTMENT_ID" ;;
    value_format_name: id
  }

  dimension: id_department {
    type: string
    sql: ${TABLE}."ID_DEPARTMENT" ;;
  }

  dimension: name_department {
    type: string
    sql: ${TABLE}."NAME_DEPARTMENT" ;;
  }

  dimension: name_full {
    type: string
    sql: ${TABLE}."NAME_FULL" ;;
  }

  dimension: type_department {
    type: string
    sql: ${TABLE}."TYPE_DEPARTMENT" ;;
  }

  dimension: status_department {
    type: string
    sql: ${TABLE}."STATUS_DEPARTMENT" ;;
  }

  dimension: name_customer_title {
    type: string
    sql: ${TABLE}."NAME_CUSTOMER_TITLE" ;;
  }

  dimension: name_state {
    type: string
    sql: ${TABLE}."NAME_STATE" ;;
  }

  dimension: name_sga_segment {
    type: string
    sql: ${TABLE}."NAME_SGA_SEGMENT" ;;
  }

  dimension: type_build_to_suit {
    type: string
    sql: ${TABLE}."TYPE_BUILD_TO_SUIT" ;;
  }

  dimension_group: date_no_longer_new_market {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_NO_LONGER_NEW_MARKET" ;;
  }

  dimension_group: date_migrated_to_vic {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_MIGRATED_TO_VIC" ;;
  }

  dimension: is_block_new_purchasing_transactions {
    type: yesno
    sql: ${TABLE}."IS_BLOCK_NEW_PURCHASING_TRANSACTIONS" ;;
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

  dimension: fk_deliver_to_contact_id {
    type: string
    sql: ${TABLE}."FK_DELIVER_TO_CONTACT_ID" ;;
  }

  dimension: fk_supervisor_user_id {
    type: number
    sql: ${TABLE}."FK_SUPERVISOR_USER_ID" ;;
    value_format_name: id
  }

  dimension: fk_parent_department_id {
    type: number
    sql: ${TABLE}."FK_PARENT_DEPARTMENT_ID" ;;
    value_format_name: id
  }

  dimension: fk_ultimate_parent_location_id {
    type: string
    sql: ${TABLE}."FK_ULTIMATE_PARENT_LOCATION_ID" ;;
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
