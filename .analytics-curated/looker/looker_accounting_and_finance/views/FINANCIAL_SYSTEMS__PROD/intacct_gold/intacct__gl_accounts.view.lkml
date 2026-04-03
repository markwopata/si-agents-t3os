view: intacct__gl_accounts {
  sql_table_name: "INTACCT_GOLD"."INTACCT__GL_ACCOUNTS" ;;

  dimension: pk_gl_account_id {
    type: number
    primary_key: yes
    sql: ${TABLE}."PK_GL_ACCOUNT_ID" ;;
    value_format_name: id
  }

  dimension: number_account {
    type: string
    sql: ${TABLE}."NUMBER_ACCOUNT" ;;
  }

  dimension: name_account {
    type: string
    sql: ${TABLE}."NAME_ACCOUNT" ;;
  }

  dimension: type_account {
    type: string
    sql: ${TABLE}."TYPE_ACCOUNT" ;;
  }

  dimension: category_account {
    type: string
    sql: ${TABLE}."CATEGORY_ACCOUNT" ;;
  }

  dimension: number_account_alternative {
    type: string
    sql: ${TABLE}."NUMBER_ACCOUNT_ALTERNATIVE" ;;
  }

  dimension: status_account {
    type: string
    sql: ${TABLE}."STATUS_ACCOUNT" ;;
  }

  dimension: balance_normal {
    type: string
    sql: ${TABLE}."BALANCE_NORMAL" ;;
  }

  dimension: type_closing {
    type: string
    sql: ${TABLE}."TYPE_CLOSING" ;;
  }

  dimension: code_tax {
    type: string
    sql: ${TABLE}."CODE_TAX" ;;
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

  dimension: is_subledger_control_on {
    type: yesno
    sql: ${TABLE}."IS_SUBLEDGER_CONTROL_ON" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_general_journal_restricted {
    type: yesno
    sql: ${TABLE}."IS_GENERAL_JOURNAL_RESTRICTED" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_subledger_restricted {
    type: yesno
    sql: ${TABLE}."IS_SUBLEDGER_RESTRICTED" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_require_class {
    type: yesno
    sql: ${TABLE}."IS_REQUIRE_CLASS" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_require_customer {
    type: yesno
    sql: ${TABLE}."IS_REQUIRE_CUSTOMER" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_require_department {
    type: yesno
    sql: ${TABLE}."IS_REQUIRE_DEPARTMENT" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_require_employee {
    type: yesno
    sql: ${TABLE}."IS_REQUIRE_EMPLOYEE" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_require_gldim_asset {
    type: yesno
    sql: ${TABLE}."IS_REQUIRE_GLDIM_ASSET" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_require_gldim_ud_loan {
    type: yesno
    sql: ${TABLE}."IS_REQUIRE_GLDIM_UD_LOAN" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_require_item {
    type: yesno
    sql: ${TABLE}."IS_REQUIRE_ITEM" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_require_location {
    type: yesno
    sql: ${TABLE}."IS_REQUIRE_LOCATION" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_require_vendor {
    type: yesno
    sql: ${TABLE}."IS_REQUIRE_VENDOR" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
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

  dimension: fk_account_category_id {
    type: string
    sql: ${TABLE}."FK_ACCOUNT_CATEGORY_ID" ;;
  }

  dimension: fk_close_to_account_id {
    type: number
    sql: ${TABLE}."FK_CLOSE_TO_ACCOUNT_ID" ;;
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
