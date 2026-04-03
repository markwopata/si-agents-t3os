include: "dim_users.view.lkml"

view: primary_salesperson {
  extends: [dim_users]

  dimension: user_key {
    primary_key: yes
    hidden: yes
  }

  dimension: user_full_name {
    label: "Primary Salesperson Full Name"
    sql: ${TABLE}."USER_FIRST_NAME" || ' ' || ${TABLE}."USER_LAST_NAME" ;;
  }

  dimension: user_email {
    label: "Primary Salesperson Email"
    sql: ${TABLE}."USER_EMAIL" ;;
  }

  dimension: user_id {
    label: "Primary Salesperson User ID"
    sql: ${TABLE}."USER_ID" ;;
  }
}
