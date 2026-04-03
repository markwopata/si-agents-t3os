view: docebo_users {
    # # You can specify the table name if it's different from the view name:
    sql_table_name:"ANALYTICS"."DOCEBO"."USERS";;
    #
    # # Define your dimensions and measures here, like this:
    dimension: user_id {
      primary_key: yes
      label: "User ID"
      type: number
      sql: ${TABLE}."USER_ID";;
    }

    dimension: username {
      type:  string
      sql:  ${TABLE}."USERNAME" ;;
    }

    dimension: first_name {
      type:  string
      sql:  ${TABLE}."FIRST_NAME";;
    }

    dimension: last_name {
      type:  string
      sql:  ${TABLE}."LAST_NAME" ;;
    }

    dimension: email {
      type: string
      sql: ${TABLE}."EMAIL" ;;
    }

    dimension: market_name {
      type: string
      sql: ${TABLE}."FIELD_47" ;;
    }

  dimension: manager_email {
    type: string
    sql: ${TABLE}."FIELD_11" ;;
  }

    measure: user_count {
      type:  count_distinct
      drill_fields: [user_details*]
      sql: ${user_id} ;;
    }

  set: user_details {
    fields: [user_id, first_name, last_name, market_name, email, manager_email, docebo_user_status.has_overdue, docebo_historical_enrollment.course_count, docebo_historical_enrollment.completed_count, docebo_historical_enrollment.overdue_count]
  }
}
