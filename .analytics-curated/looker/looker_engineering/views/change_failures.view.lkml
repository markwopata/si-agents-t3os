view: change_failures {
  derived_table: {
    sql: with cards as (
        select
          cards.team card_team
          ,cards.id card_id
          ,cards.name card_name
          ,concat('https://app.shortcut.com/equipmentshare/story/', id) card_link
          ,to_date(coalesce(completed_at, started_at, created_at), 'yyyy/mm/dd hh24:mi:ss') change_failure_date
        from analytics.gs.engineering_shortcut_stories cards
        where {% condition cf_team %} cards.team {% endcondition %}
        and {% condition cf_week %} to_date(coalesce(completed_at, started_at, created_at), 'yyyy/mm/dd hh24:mi:ss') {% endcondition %}
        and contains(cards.labels,'change_failure')
      )
      ,deploys as (
        select deploys.team deployment_team
          ,deploys.group_name
          ,deploys.project_name
          ,deploys.username
          ,deploys.pipeline_web_url pipeline_link
          ,deploys.created_date deployment_date
        from es_warehouse.public.eng_prod_deployments deploys
        where {% condition cf_team %} deploys.team {% endcondition %}
      )
      select cards.card_team
      ,cards.card_id
      ,cards.card_name
      ,cards.card_link
      ,cards.change_failure_date
      ,deploys.deployment_team
      ,deploys.group_name
      ,deploys.project_name
      ,deploys.username
      ,deploys.pipeline_link
      ,deploys.deployment_date
      from cards
      full outer join deploys
        on deploys.deployment_team = cards.card_team
      where {% condition cf_week %} deploys.deployment_date {% endcondition %}
      ;;

  }

  filter: cf_week {
    type: date
  }

  filter: cf_team {
    type: string
  }

  dimension: card_team {
    type: string
    sql: ${TABLE}.card_team ;;
  }

  dimension: card_id {
    type: string
    sql:  ${TABLE}.card_id ;;
  }

  dimension: card_name {
    type: string
    sql:  ${TABLE}.card_name ;;
  }

  dimension: card_link {
    type:  string
    sql: ${TABLE}.card_link ;;
    html: <a href="{{rendered_value}}">{{rendered_value}}</a> ;;
  }

  dimension_group: change_failure {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.change_failure_date;;
  }

  dimension: deployment_team {
    type: string
    sql: ${TABLE}.deployment_team ;;
  }

  dimension: group_name {
    type: string
    sql: ${TABLE}.group_name ;;
  }

  dimension: project_name {
    type: string
    sql: ${TABLE}.project_name ;;
  }

  dimension: username {
    type: string
    sql: ${TABLE}.username ;;
  }

  dimension: pipeline_link {
    type: string
    sql: ${TABLE}.pipeline_link ;;
    html: <a href="{{rendered_value}}">{{rendered_value}}</a> ;;
  }

  dimension_group: deployment {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.deployment_date ;;
  }

  measure: total_change_failures {
    type: count_distinct
    sql: ${card_team} || ${card_id} ;;
    drill_fields: [card_team, card_name, card_link, change_failure_date]
  }

  measure: total_deployments {
    type: count_distinct
    sql: ${deployment_team} || ${pipeline_link} ;;
    drill_fields: [deployment_team, group_name, project_name, username, pipeline_link, deployment_date]
  }

  measure: change_failure_rate {
    type: string
    sql: concat(case when ${total_change_failures} is null or ${total_change_failures} = 0 then '0.00' else ((${total_change_failures}/ifnull(${total_deployments},1)*100)::numeric(10,2))::varchar end,'%');;
    drill_fields: [card_team, card_name, card_link, change_failure_date]
  }
}
