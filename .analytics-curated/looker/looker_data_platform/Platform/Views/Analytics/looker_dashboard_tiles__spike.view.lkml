view: looker_dashboard_tiles__spike {
  sql_table_name: "BI_OPS"."LOOKER_DASHBOARD_TILES__SPIKE" ;;

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
  dimension: tile_note {
    type: string
    sql: ${TABLE}."TILE_NOTE" ;;
    description: "More information about what the title is representing or what the timeframe of the tile is looking at"
  }
  dimension: tile_title {
    type: string
    sql: ${TABLE}."TILE_TITLE" ;;
    description: "Name or subject of the specific tile on the dashboard"
  }
  dimension: tile_type {
    type: string
    sql: ${TABLE}."TILE_TYPE" ;;
    hidden: yes
  }
  dimension: folder_name {
    type: string
    sql: ${TABLE}."FOLDER_NAME" ;;
  }

  dimension: dashboard_search {
    type: string
    sql: ${TABLE}."DASHBOARD_SEARCH" ;;
    description: "The field contains dashboard title, dashboard description, dashboard tiles and dashboard tile notes. Each comma seperates those fields and dashboard description and dashboard tile notes may just have blank for them"
  }
  dimension: dashboard_description {
    type: string
    sql: ${TABLE}."DASHBOARD_DESCRIPTION" ;;
    description: "This contains metrics that are on the dashboards and describes what information the dashboard has"
  }

  dimension: dashboard_view_count {
    type: number
    sql: ${TABLE}."DASHBOARD_VIEW_COUNT" ;;
    description: "How many total views a dashboard has giving insight to how popular or accessed it is"
  }

  dimension: dashboard_favorite_count {
    type: number
    sql: ${TABLE}."DASHBOARD_FAVORITE_COUNT" ;;
    description: "How many users have favortied this dashboard in Looker"
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
  measure: count {
    type: count
    hidden: yes
  }
}
