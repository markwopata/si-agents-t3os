view: users {
  sql_table_name: "PEOPLE_ANALYTICS"."DOCEBO"."USERS" ;;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ID" ;;
  }
  dimension: _fivetran_deleted {
    type: yesno
    sql: ${TABLE}."_FIVETRAN_DELETED" ;;
  }
  dimension: _fivetran_synced {
    type: date_raw
    sql: ${TABLE}."_FIVETRAN_SYNCED";;
  }
  dimension: actions {
    type: string
    sql: ${TABLE}."ACTIONS" ;;
  }
  dimension: avatar {
    type: string
    sql: ${TABLE}."AVATAR" ;;
  }
  dimension: creation_date {
    type: date_raw
    sql: ${TABLE}."CREATION_DATE" ;;
  }
  dimension: custom_active_subordinates_count {
    type: number
    sql: ${TABLE}."CUSTOM_ACTIVE_SUBORDINATES_COUNT" ;;
  }
  dimension: employee_title {
    type: string
    sql: ${TABLE}."CUSTOM_FIELD_1" ;;
  }
  dimension: manager_employee_id {
    type: string
    sql: ${TABLE}."CUSTOM_FIELD_10" ;;
  }
  dimension: manager_email {
    type: string
    sql: ${TABLE}."CUSTOM_FIELD_11" ;;
  }
  dimension: location_name {
    type: string
    sql: ${TABLE}."CUSTOM_FIELD_12" ;;
  }
  dimension: division {
    type: string
    sql: ${TABLE}."CUSTOM_FIELD_14" ;;
  }
  dimension: are_you_a_manager {
    type: string
    sql: ${TABLE}."CUSTOM_FIELD_15" ;;
  }
  dimension: hourly_salary {
    type: string
    sql: ${TABLE}."CUSTOM_FIELD_16" ;;
  }
  dimension: rehired {
    type: string
    sql: ${TABLE}."CUSTOM_FIELD_17" ;;
  }
  dimension: rehired_date {
    type: date_raw
    sql: ${TABLE}."CUSTOM_FIELD_18" ;;
  }
  dimension: employee_status {
    type: string
    sql: ${TABLE}."CUSTOM_FIELD_19" ;;
  }
  dimension: hire_date {
    type: date_raw
    sql: ${TABLE}."CUSTOM_FIELD_2" ;;
  }
  dimension: state {
    type: string
    sql: ${TABLE}."CUSTOM_FIELD_20" ;;
  }
  dimension: on_leave {
    type: string
    sql: ${TABLE}."CUSTOM_FIELD_21" ;;
  }
  dimension: t_shirt_size {
    type: string
    sql: ${TABLE}."CUSTOM_FIELD_22" ;;
  }
  dimension: dietary_restrictions {
    type: string
    sql: ${TABLE}."CUSTOM_FIELD_25" ;;
  }
  dimension: enter_your_dietary_restrictions {
    type: string
    sql: ${TABLE}."CUSTOM_FIELD_26" ;;
  }
  dimension: district {
    type: string
    sql: ${TABLE}."CUSTOM_FIELD_27" ;;
  }
  dimension: customer_employee {
    type: string
    sql: ${TABLE}."CUSTOM_FIELD_28" ;;
  }
  dimension: provided_ipad_iphone {
    type: string
    sql: ${TABLE}."CUSTOM_FIELD_29" ;;
  }
  dimension: expertise_level {
    type: string
    sql: ${TABLE}."CUSTOM_FIELD_3" ;;
  }
  dimension: disc {
    type: string
    sql: ${TABLE}."CUSTOM_FIELD_30" ;;
  }
  dimension: vehicle {
    type: string
    sql: ${TABLE}."CUSTOM_FIELD_31" ;;
  }
  dimension: tenure_more_than_7_days {
    type: string
    sql: ${TABLE}."CUSTOM_FIELD_35" ;;
  }
  dimension: tenure_more_than_14_days {
    type: string
    sql: ${TABLE}."CUSTOM_FIELD_36" ;;
  }
  dimension: tenure_more_than_30_days {
    type: string
    sql: ${TABLE}."CUSTOM_FIELD_37" ;;
  }
  dimension: tenure_more_than_60_days {
    type: string
    sql: ${TABLE}."CUSTOM_FIELD_38" ;;
  }
  dimension: tenure_more_than_90_days {
    type: string
    sql: ${TABLE}."CUSTOM_FIELD_39" ;;
  }
  dimension: employee_id {
    type: string
    sql: ${TABLE}."CUSTOM_FIELD_4" ;;
  }
  dimension: tenure_more_than_180_days {
    type: string
    sql: ${TABLE}."CUSTOM_FIELD_40" ;;
  }
  dimension: tenure_more_than_3_years {
    type: string
    sql: ${TABLE}."CUSTOM_FIELD_41" ;;
  }
  dimension: region {
    type: string
    sql: ${TABLE}."CUSTOM_FIELD_42" ;;
  }
  dimension: termination_date {
    type: date_raw
    sql: ${TABLE}."CUSTOM_FIELD_43" ;;
  }
  dimension: remote {
    type: string
    sql: ${TABLE}."CUSTOM_FIELD_44" ;;
  }
  dimension: company_tenure {
    type: string
    sql: ${TABLE}."CUSTOM_FIELD_45" ;;
  }
  dimension: tax_location {
    type: string
    sql: ${TABLE}."CUSTOM_FIELD_47" ;;
  }
  dimension: job_last_changed_date {
    type: date_raw
    sql: ${TABLE}."CUSTOM_FIELD_48" ;;
  }
  dimension: rate_type {
    type: string
    sql: ${TABLE}."CUSTOM_FIELD_5" ;;
  }
  dimension: unenrollment_notes {
    type: string
    sql: ${TABLE}."CUSTOM_FIELD_50" ;;
  }
  dimension: test_user {
    type: string
    sql: ${TABLE}."CUSTOM_FIELD_51" ;;
  }
  dimension: advanced_solutions {
    type: string
    sql: ${TABLE}."CUSTOM_FIELD_52" ;;
  }
  dimension: landmark {
    type: string
    sql: ${TABLE}."CUSTOM_FIELD_53" ;;
  }
  dimension: work_location {
    type: string
    sql: ${TABLE}."CUSTOM_FIELD_6" ;;
  }
  dimension: department_code {
    type: string
    sql: ${TABLE}."CUSTOM_FIELD_7" ;;
  }
  dimension: department_name {
    type: string
    sql: ${TABLE}."CUSTOM_FIELD_8" ;;
  }
  dimension: manager {
    type: string
    sql: ${TABLE}."CUSTOM_FIELD_9" ;;
  }
  dimension: email {
    type: string
    sql: ${TABLE}."EMAIL" ;;
  }
  dimension: email_validation_status {
    type: number
    sql: ${TABLE}."EMAIL_VALIDATION_STATUS" ;;
  }
  dimension: encoded_username {
    type: string
    sql: ${TABLE}."ENCODED_USERNAME" ;;
  }
  dimension: expired {
    type: yesno
    sql: ${TABLE}."EXPIRED" ;;
  }
  dimension: first_name {
    type: string
    sql: ${TABLE}."FIRST_NAME" ;;
  }
  dimension: fullname {
    type: string
    sql: ${TABLE}."FULLNAME" ;;
  }
  dimension: is_manager {
    type: yesno
    sql: ${TABLE}."IS_MANAGER" ;;
  }
  dimension: lang_code {
    type: string
    sql: ${TABLE}."LANG_CODE" ;;
  }
  dimension: languages {
    type: string
    sql: ${TABLE}."LANGUAGES" ;;
  }
  dimension: last_access {
    type: date_raw
    sql: ${TABLE}."LAST_ACCESS_DATE" ;;
  }
  dimension: last_name {
    type: string
    sql: ${TABLE}."LAST_NAME" ;;
  }
  dimension: last_update {
    type: date_raw
    sql: ${TABLE}."LAST_UPDATE" ;;
  }
  dimension: level {
    type: string
    sql: ${TABLE}."LEVEL" ;;
  }
  dimension: multi_domains {
    type: string
    sql: ${TABLE}."MULTI_DOMAINS" ;;
  }
  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }
  dimension: newsletter_optout {
    type: number
    sql: ${TABLE}."NEWSLETTER_OPTOUT" ;;
  }
  dimension: send_notification {
    type: number
    sql: ${TABLE}."SEND_NOTIFICATION" ;;
  }
  dimension: status {
    type: number
    sql: ${TABLE}."STATUS" ;;
  }
  dimension: timezone {
    type: string
    sql: ${TABLE}."TIMEZONE" ;;
  }
  dimension: uuid {
    type: string
    sql: ${TABLE}."UUID" ;;
  }
  measure: count {
    type: count
  }

}
