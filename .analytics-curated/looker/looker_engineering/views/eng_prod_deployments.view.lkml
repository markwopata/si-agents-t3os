view: eng_prod_deployments {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."ENG_PROD_DEPLOYMENTS"
    ;;

  dimension: branch_name {
    type: string
    sql: ${TABLE}."BRANCH_NAME" ;;
  }

  dimension_group: created {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."CREATED_DATE" ;;
  }

  dimension: group_name {
    type: string
    sql: ${TABLE}."GROUP_NAME" ;;
  }

  dimension: pipeline_web_url {
    type:  string
    sql: ${TABLE}."PIPELINE_WEB_URL" ;;
    html: <a href="{{rendered_value}}">{{rendered_value}}</a> ;;
  }

  dimension: project_name {
    type: string
    sql: ${TABLE}."PROJECT_NAME" ;;
  }

  dimension: project_web_url {
    type: string
    sql: ${TABLE}."PROJECT_WEB_URL" ;;
  }

  dimension: team {
    type: string
    sql: ${TABLE}."TEAM" ;;
  }

  dimension: username {
    type: string
    sql: ${TABLE}."USERNAME" ;;
  }

  measure: count {
    type: count
    drill_fields: [team, group_name, project_name, username, pipeline_web_url, created_date]
  }
}
