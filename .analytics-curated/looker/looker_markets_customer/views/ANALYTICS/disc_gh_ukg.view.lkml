view: disc_gh_ukg {
  # You can specify the table name if it's different from the view name:
  sql_table_name: "PUBLIC"."DISC_GH_UKG" ;;

  # Define your dimensions and measures here, like this:
  dimension: employee_id {
    type: number
    sql: ${TABLE}.employee_id ;;
  }

  dimension: disc_code {
    type: string
    sql: ${TABLE}.disc_code ;;
  }

  dimension: greenhouse_application_id {
    type: number
    sql: ${TABLE}.external_id ;;
  }

}
