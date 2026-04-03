view: sales_track_logins {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."SALES_TRACK_LOGINS"
    ;;
  drill_fields: [sales_track_login_id]

  dimension: sales_track_login_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."SALES_TRACK_LOGIN_ID" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: date_added {
    type: string
    sql: ${TABLE}."DATE_ADDED" ;;
  }

  dimension: login_link {
    type: string
    sql: ${TABLE}."LOGIN_LINK" ;;
  }

  dimension: token {
    type: string
    sql: ${TABLE}."TOKEN" ;;
  }

  dimension: fleet_login_link {
    type: string
    sql: ${TABLE}."FLEET_LOGIN_LINK" ;;
  }

  dimension: analytics_login_link {
    type: string
    sql: ${TABLE}."ANALYTICS_LOGIN_LINK" ;;
  }

  measure: count {
    type: count
    drill_fields: [sales_track_login_id]
  }
}
