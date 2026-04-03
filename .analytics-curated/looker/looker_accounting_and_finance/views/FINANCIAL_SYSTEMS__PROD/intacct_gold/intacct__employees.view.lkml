view: intacct__employees {
  sql_table_name: "INTACCT_GOLD"."INTACCT__EMPLOYEES" ;;

  dimension: pk_employee_id {
    type: number
    primary_key: yes
    sql: ${TABLE}."PK_EMPLOYEE_ID" ;;
    value_format_name: id
  }

  dimension: name_contact {
    type: string
    sql: ${TABLE}."NAME_CONTACT" ;;
  }

  dimension: name_first {
    type: string
    sql: ${TABLE}."NAME_FIRST" ;;
  }

  dimension: name_last {
    type: string
    sql: ${TABLE}."NAME_LAST" ;;
  }

  dimension: status_employee {
    type: string
    sql: ${TABLE}."STATUS_EMPLOYEE" ;;
  }

  dimension: type_employee {
    type: string
    sql: ${TABLE}."TYPE_EMPLOYEE" ;;
  }

  dimension: name_title {
    type: string
    sql: ${TABLE}."NAME_TITLE" ;;
  }

  dimension_group: date_start {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_START" ;;
  }

  dimension_group: date_end {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_END" ;;
  }

  dimension: type_termination {
    type: string
    sql: ${TABLE}."TYPE_TERMINATION" ;;
  }

  dimension: type_ach_account {
    type: string
    sql: ${TABLE}."TYPE_ACH_ACCOUNT" ;;
  }

  dimension: type_ach_remittance {
    type: string
    sql: ${TABLE}."TYPE_ACH_REMITTANCE" ;;
  }

  dimension: is_payment_notify {
    type: yesno
    sql: ${TABLE}."IS_PAYMENT_NOTIFY" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_post_actual_cost {
    type: yesno
    sql: ${TABLE}."IS_POST_ACTUAL_COST" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_ach_enabled {
    type: yesno
    sql: ${TABLE}."IS_ACH_ENABLED" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_generic {
    type: yesno
    sql: ${TABLE}."IS_GENERIC" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
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

  dimension: fk_contact_id {
    type: number
    sql: ${TABLE}."FK_CONTACT_ID" ;;
    value_format_name: id
  }

  dimension: fk_employee_id {
    type: string
    sql: ${TABLE}."FK_EMPLOYEE_ID" ;;
  }

  dimension: fk_department_id {
    type: number
    sql: ${TABLE}."FK_DEPARTMENT_ID" ;;
    value_format_name: id
  }

  dimension: fk_location_id {
    type: number
    sql: ${TABLE}."FK_LOCATION_ID" ;;
    value_format_name: id
  }

  dimension: fk_entity_id {
    type: string
    sql: ${TABLE}."FK_ENTITY_ID" ;;
  }

  dimension: fk_mega_entity_id {
    type: number
    sql: ${TABLE}."FK_MEGA_ENTITY_ID" ;;
    value_format_name: id
  }

  dimension: fk_parent_id {
    type: number
    sql: ${TABLE}."FK_PARENT_ID" ;;
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
