view: intacct__locations {
  sql_table_name: "INTACCT_GOLD"."INTACCT__LOCATIONS" ;;

  dimension: pk_location_id {
    type: number
    primary_key: yes
    sql: ${TABLE}."PK_LOCATION_ID" ;;
    value_format_name: id
  }

  dimension: id_location {
    type: string
    sql: ${TABLE}."ID_LOCATION" ;;
  }

  dimension: name_location {
    type: string
    sql: ${TABLE}."NAME_LOCATION" ;;
  }

  dimension: status_location {
    type: string
    sql: ${TABLE}."STATUS_LOCATION" ;;
  }

  dimension: name_print_as {
    type: string
    sql: ${TABLE}."NAME_PRINT_AS" ;;
  }

  dimension: business_days {
    type: string
    sql: ${TABLE}."BUSINESS_DAYS" ;;
  }

  dimension: id_tax {
    type: string
    sql: ${TABLE}."ID_TAX" ;;
  }

  dimension: id_tax_alt {
    type: string
    sql: ${TABLE}."ID_TAX_ALT" ;;
  }

  dimension: num_first_month {
    type: string
    sql: ${TABLE}."NUM_FIRST_MONTH" ;;
  }

  dimension: num_first_month_tax {
    type: string
    sql: ${TABLE}."NUM_FIRST_MONTH_TAX" ;;
  }

  dimension: is_ie_relation {
    type: yesno
    sql: ${TABLE}."IS_IE_RELATION" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_root_location {
    type: string
    sql: ${TABLE}."IS_ROOT_LOCATION" ;;
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

  dimension: fk_parent_location_id {
    type: number
    sql: ${TABLE}."FK_PARENT_LOCATION_ID" ;;
    value_format_name: id
  }

  dimension: fk_ship_to_contact_id {
    type: number
    sql: ${TABLE}."FK_SHIP_TO_CONTACT_ID" ;;
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
