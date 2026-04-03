view: intacct__users {
  sql_table_name: "INTACCT_GOLD"."INTACCT__USERS" ;;

  dimension: pk_user_id {
    type: number
    primary_key: yes
    sql: ${TABLE}."PK_USER_ID" ;;
    value_format_name: id
  }

  dimension: id_login {
    type: string
    sql: ${TABLE}."ID_LOGIN" ;;
  }

  dimension: status_user {
    type: string
    sql: ${TABLE}."STATUS_USER" ;;
  }

  dimension: type_user {
    type: string
    sql: ${TABLE}."TYPE_USER" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: notes_user_access {
    type: string
    sql: ${TABLE}."NOTES_USER_ACCESS" ;;
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

  dimension: is_unrestricted {
    type: yesno
    sql: ${TABLE}."IS_UNRESTRICTED" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_chatter_disabled {
    type: yesno
    sql: ${TABLE}."IS_CHATTER_DISABLED" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_able_to_post_pos_to_d365_markets {
    type: yesno
    sql: ${TABLE}."IS_ABLE_TO_POST_POS_TO_D365_MARKETS" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_able_to_post_pos_to_new_construction_markets {
    type: yesno
    sql: ${TABLE}."IS_ABLE_TO_POST_POS_TO_NEW_CONSTRUCTION_MARKETS" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_has_access_to_22xx_tax_accounts {
    type: yesno
    sql: ${TABLE}."IS_HAS_ACCESS_TO_22XX_TAX_ACCOUNTS" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_has_access_to_s1_concor_insurance_group {
    type: yesno
    sql: ${TABLE}."IS_HAS_ACCESS_TO_S1_CONCOR_INSURANCE_GROUP" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_password_never_expires {
    type: yesno
    sql: ${TABLE}."IS_PASSWORD_NEVER_EXPIRES" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_password_quality_not_enforced {
    type: yesno
    sql: ${TABLE}."IS_PASSWORD_QUALITY_NOT_ENFORCED" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_reset_password {
    type: yesno
    sql: ${TABLE}."IS_RESET_PASSWORD" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: is_login_disabled {
    type: yesno
    sql: ${TABLE}."IS_LOGIN_DISABLED" ;;
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

  dimension: fk_contact_id {
    type: number
    sql: ${TABLE}."FK_CONTACT_ID" ;;
    value_format_name: id
  }

  dimension: fk_shared_user_id_access {
    type: string
    sql: ${TABLE}."FK_SHARED_USER_ID_ACCESS" ;;
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
