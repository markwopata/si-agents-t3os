view: dim_users {
  sql_table_name: "PLATFORM"."GOLD"."V_USERS" ;;
  drill_fields: [user_key]

  dimension: user_key {
    primary_key: yes
    type: string
    sql: ${TABLE}."USER_KEY" ;;
    description: "Surrogate key for users (salespeople)"
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
    description: "Natural key for users"
  }

  dimension: user_source {
    type: string
    sql: ${TABLE}."USER_SOURCE" ;;
    description: "Source system for user data"
  }

  dimension: user_first_name {
    type: string
    sql: ${TABLE}."USER_FIRST_NAME" ;;
    description: "User's first name"
  }

  dimension: user_last_name {
    type: string
    sql: ${TABLE}."USER_LAST_NAME" ;;
    description: "User's last name"
  }

  dimension: user_full_name {
    type: string
    sql: ${TABLE}."USER_FIRST_NAME" || ' ' || ${TABLE}."USER_LAST_NAME" ;;
    description: "User's full name"
  }

  dimension: user_email {
    type: string
    sql: ${TABLE}."USER_EMAIL" ;;
    description: "User's email address"
  }

  dimension: user_phone {
    type: string
    sql: ${TABLE}."USER_PHONE" ;;
    description: "User's phone number"
  }

  dimension: user_company_id {
    type: number
    sql: ${TABLE}."USER_COMPANY_ID" ;;
    description: "Company ID the user belongs to"
  }

  dimension: user_company_name {
    type: string
    sql: ${TABLE}."USER_COMPANY_NAME" ;;
    description: "Company name the user belongs to"
  }

  dimension: user_company_key {
    type: string
    sql: ${TABLE}."USER_COMPANY_KEY" ;;
    description: "Company surrogate key"
  }

  dimension: user_security_level_id {
    type: number
    sql: ${TABLE}."USER_SECURITY_LEVEL_ID" ;;
    description: "User's security level (1=Admin, 2=Manager, 3=User)"
  }

  dimension: user_security_level_name {
    type: string
    sql: ${TABLE}."USER_SECURITY_LEVEL_NAME" ;;
    description: "User's security level name"
  }

  dimension: user_active {
    type: yesno
    sql: ${TABLE}."USER_ACTIVE" ;;
    description: "Whether the user is active"
  }

  dimension: user_created_date {
    type: date
    sql: ${TABLE}."USER_CREATED_DATE" ;;
    description: "Date the user was created"
  }

  dimension: user_updated_date {
    type: date
    sql: ${TABLE}."USER_UPDATED_DATE" ;;
    description: "Date the user was last updated"
  }

  # Measures for salesperson performance
  measure: count_of_users {
    type: count
    description: "Total number of users"
  }

  measure: count_of_active_users {
    type: count
    filters: [user_active: "Yes"]
    description: "Number of active users"
  }

  measure: count_of_salespeople {
    type: count
    filters: [user_security_level_id: "3"]
    description: "Number of salespeople (security level 3)"
  }

  measure: count_of_managers {
    type: count
    filters: [user_security_level_id: "2"]
    description: "Number of managers (security level 2)"
  }

  measure: count_of_admins {
    type: count
    filters: [user_security_level_id: "1"]
    description: "Number of admins (security level 1)"
  }
}
