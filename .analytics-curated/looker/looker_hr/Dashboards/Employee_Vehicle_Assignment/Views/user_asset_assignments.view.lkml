#
# The purpose of this view is to get user and vehicle asset information for HR
# reference to send new drivers appropriate policies and training.
#
# Britt Shanklin | Built 2022-06-16
view: user_asset_assignments {
  sql_table_name: "SWORKS"."VEHICLE_USAGE_TRACKER"."USER_ASSET_ASSIGNMENTS" ;;

  dimension: assignment_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."USER_ASSET_ASSIGNMENT_ID" ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: start_date {
    type: date
    sql: ${TABLE}."START_DATE" ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  dimension: end_date {
    type: date
    sql: ${TABLE}."END_DATE" ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  dimension: current_assignment {
    type: yesno
    sql: ${end_date} is null ;;
  }

}
