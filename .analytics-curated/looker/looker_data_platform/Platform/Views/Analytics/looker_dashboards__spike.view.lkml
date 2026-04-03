view: looker_dashboards__spike {
  sql_table_name: "ANALYTICS"."BI_OPS"."LOOKER_DASHBOARDS__SPIKE" ;;

  dimension: dashboard_id {
    type: string
    sql: ${TABLE}."DASHBOARD_ID" ;;
    hidden: yes
  }
  dimension: dashboard_title {
    type: string
    sql: ${TABLE}."DASHBOARD_TITLE" ;;
    description: "This contains the name of the dashboard"
  }
  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
    description: "This contains metrics that are on the dashboards and describes what information the dashboard has"
  }
  dimension: title_description_combo {
    type: string
    sql: ${TABLE}."DASHBOARD_TITLE" || ' ' || ${TABLE}."DESCRIPTION" ;;
    hidden: yes
  }
  dimension: favorite_count {
    type: number
    sql: ${TABLE}."FAVORITE_COUNT" ;;
    value_format_name: decimal_0
    description: "How many total favorites are on a dashboard. Suggesting how popular it is to users."
  }
  dimension: folder_id {
    type: string
    sql: ${TABLE}."FOLDER_ID" ;;
    hidden: yes
  }
  dimension: folder_name {
    type: string
    sql: ${TABLE}."FOLDER_NAME" ;;
    description: "Gives the name of the folder the dashboard lives in."
  }
  dimension: has_description {
    type: yesno
    sql: ${TABLE}."HAS_DESCRIPTION" ;;
    hidden: yes
  }
  dimension: view_count {
    type: number
    sql: ${TABLE}."VIEW_COUNT" ;;
    value_format_name: decimal_0
    description: "How many total views are on a dashboard. Suggesting how popular it is to users."
  }
  measure: count {
    type: count
    drill_fields: [folder_name]
    hidden: yes
  }

 dimension: dashboard_link {
  type: string
  sql: concat('https://equipmentshare.looker.com/dashboards/', ${dashboard_id}) ;;
  html:
    <a href="{{ rendered_value }}" target="_blank" style="color:#0063f3;">
      Dashboard Link
    </a> ;;
  description: "This contains a link to the dashboard that users can put into the web address"
}

}
