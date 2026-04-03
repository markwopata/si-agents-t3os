view: intacct_sandbox__users {
  sql_table_name: "GOLD"."INTACCT_SANDBOX__USERS" ;;

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }
  dimension: email {
    type: string
    sql: ${TABLE}."EMAIL" ;;
  }
  dimension: email_old {
    type: string
    sql: ${TABLE}."EMAIL_OLD" ;;
  }
  dimension: fk_contact_id {
    type: number
    sql: ${TABLE}."FK_CONTACT_ID" ;;
  }
  dimension: fk_created_by_user_id {
    type: number
    sql: ${TABLE}."FK_CREATED_BY_USER_ID" ;;
  }
  dimension: fk_extract_hash_id {
    type: number
    sql: ${TABLE}."FK_EXTRACT_HASH_ID" ;;
  }
  dimension: fk_modified_by_user_id {
    type: number
    sql: ${TABLE}."FK_MODIFIED_BY_USER_ID" ;;
  }
  dimension: fk_shared_user_id_access {
    type: number
    value_format_name: id
    sql: ${TABLE}."FK_SHARED_USER_ID_ACCESS" ;;
  }
  dimension: id_login {
    type: string
    sql: ${TABLE}."ID_LOGIN" ;;
  }
  dimension: is_able_to_post_pos_to_d365_markets {
    type: yesno
    sql: ${TABLE}."IS_ABLE_TO_POST_POS_TO_D365_MARKETS" ;;
  }
  dimension: is_able_to_post_pos_to_new_construction_markets {
    type: yesno
    sql: ${TABLE}."IS_ABLE_TO_POST_POS_TO_NEW_CONSTRUCTION_MARKETS" ;;
  }
  dimension: is_able_to_post_pos_to_t3_markets {
    type: yesno
    sql: ${TABLE}."IS_ABLE_TO_POST_POS_TO_T3_MARKETS" ;;
  }
  dimension: is_chatter_disabled {
    type: yesno
    sql: ${TABLE}."IS_CHATTER_DISABLED" ;;
  }
  dimension: is_has_access_to_22_xx_tax_accounts {
    type: yesno
    sql: ${TABLE}."IS_HAS_ACCESS_TO_22XX_TAX_ACCOUNTS" ;;
  }
  dimension: is_has_access_to_s1_concor_insurance_group {
    type: yesno
    sql: ${TABLE}."IS_HAS_ACCESS_TO_S1_CONCOR_INSURANCE_GROUP" ;;
  }
  dimension: is_login_disabled {
    type: yesno
    sql: ${TABLE}."IS_LOGIN_DISABLED" ;;
  }
  dimension: is_password_never_expires {
    type: yesno
    sql: ${TABLE}."IS_PASSWORD_NEVER_EXPIRES" ;;
  }
  dimension: is_password_quality_not_enforced {
    type: yesno
    sql: ${TABLE}."IS_PASSWORD_QUALITY_NOT_ENFORCED" ;;
  }
  dimension: is_reset_password {
    type: yesno
    sql: ${TABLE}."IS_RESET_PASSWORD" ;;
  }
  dimension: is_unrestricted {
    type: yesno
    sql: ${TABLE}."IS_UNRESTRICTED" ;;
  }
  dimension: is_visible {
    type: yesno
    sql: ${TABLE}."IS_VISIBLE" ;;
  }
  dimension: name_file {
    type: string
    sql: ${TABLE}."NAME_FILE" ;;
  }
  dimension: notes_user_access {
    type: string
    sql: ${TABLE}."NOTES_USER_ACCESS" ;;
  }
  dimension: pk_user_id {
    type: number
    sql: ${TABLE}."PK_USER_ID" ;;
  }
  dimension: status_user {
    type: string
    sql: ${TABLE}."STATUS_USER" ;;
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
  dimension: type_user {
    type: string
    sql: ${TABLE}."TYPE_USER" ;;
  }
  measure: count {
    type: count
  }
}
