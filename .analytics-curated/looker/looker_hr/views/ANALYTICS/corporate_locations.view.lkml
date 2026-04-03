view: corporate_locations {
  sql_table_name: "ANALYTICS"."PUBLIC"."CORPORATE_LOCATIONS" ;;

  dimension: address {
    type: string
    sql: ${TABLE}."ADDRESS" ;;
  }

  dimension: number {
    label: "Phone Number"
    sql: ${TABLE}."NUMBER" ;;
  }

  dimension: email_s_ {
    label: "Email"
    sql: ${TABLE}."EMAIL_S_" ;;
  }

  dimension: name {
    label: "Corporate Location Name"
    type: string
    sql: ${TABLE}."NAME" ;;
  }

}
