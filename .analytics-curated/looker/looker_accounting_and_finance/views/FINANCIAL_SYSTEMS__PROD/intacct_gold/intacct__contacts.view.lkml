view: intacct__contacts {
  sql_table_name: "INTACCT_GOLD"."INTACCT__CONTACTS" ;;

  dimension: pk_contact_id {
    type: number
    primary_key: yes
    sql: ${TABLE}."PK_CONTACT_ID" ;;
    value_format_name: id
  }

  dimension: name_contact {
    type: string
    sql: ${TABLE}."NAME_CONTACT" ;;
  }

  dimension: name_prefix {
    type: string
    sql: ${TABLE}."NAME_PREFIX" ;;
  }

  dimension: name_first {
    type: string
    sql: ${TABLE}."NAME_FIRST" ;;
  }

  dimension: name_initial {
    type: string
    sql: ${TABLE}."NAME_INITIAL" ;;
  }

  dimension: name_last {
    type: string
    sql: ${TABLE}."NAME_LAST" ;;
  }

  dimension: name_full {
    type: string
    sql: ${TABLE}."NAME_FULL" ;;
  }

  dimension: name_print_as {
    type: string
    sql: ${TABLE}."NAME_PRINT_AS" ;;
  }

  dimension: name_company {
    type: string
    sql: ${TABLE}."NAME_COMPANY" ;;
  }

  dimension: status_contact {
    type: string
    sql: ${TABLE}."STATUS_CONTACT" ;;
  }

  dimension: email_primary {
    type: string
    sql: ${TABLE}."EMAIL_PRIMARY" ;;
  }

  dimension: email_secondary {
    type: string
    sql: ${TABLE}."EMAIL_SECONDARY" ;;
  }

  dimension: phone_primary {
    type: string
    sql: ${TABLE}."PHONE_PRIMARY" ;;
  }

  dimension: phone_secondary {
    type: string
    sql: ${TABLE}."PHONE_SECONDARY" ;;
  }

  dimension: phone_fax {
    type: string
    sql: ${TABLE}."PHONE_FAX" ;;
  }

  dimension: phone_cell {
    type: string
    sql: ${TABLE}."PHONE_CELL" ;;
  }

  dimension: phone_pager {
    type: string
    sql: ${TABLE}."PHONE_PAGER" ;;
  }

  dimension: address_line_1 {
    type: string
    sql: ${TABLE}."ADDRESS_LINE_1" ;;
  }

  dimension: address_line_2 {
    type: string
    sql: ${TABLE}."ADDRESS_LINE_2" ;;
  }

  dimension: address_city {
    type: string
    sql: ${TABLE}."ADDRESS_CITY" ;;
  }

  dimension: address_state {
    type: string
    sql: ${TABLE}."ADDRESS_STATE" ;;
  }

  dimension: address_zip {
    type: string
    sql: ${TABLE}."ADDRESS_ZIP" ;;
  }

  dimension: address_country {
    type: string
    sql: ${TABLE}."ADDRESS_COUNTRY" ;;
  }

  dimension: address_country_code {
    type: string
    sql: ${TABLE}."ADDRESS_COUNTRY_CODE" ;;
  }

  dimension: address_latitude {
    type: number
    sql: ${TABLE}."ADDRESS_LATITUDE" ;;
  }

  dimension: address_longitude {
    type: number
    sql: ${TABLE}."ADDRESS_LONGITUDE" ;;
  }

  dimension: id_tax {
    type: string
    sql: ${TABLE}."ID_TAX" ;;
  }

  dimension: is_taxable {
    type: yesno
    sql: ${TABLE}."IS_TAXABLE" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_visible {
    type: yesno
    sql: ${TABLE}."IS_VISIBLE" ;;
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

  dimension: fk_tax_group_id {
    type: number
    sql: ${TABLE}."FK_TAX_GROUP_ID" ;;
    value_format_name: id
  }

  dimension: fk_mega_entity_id {
    type: number
    sql: ${TABLE}."FK_MEGA_ENTITY_ID" ;;
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
