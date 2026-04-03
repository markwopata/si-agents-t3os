view: vip_feature_requests {
  derived_table: {
    sql:
 with splitting_labels_feature_requets as (
select
    id,
    TO_CHAR(TO_TIMESTAMP(created_at, 'YYYY/MM/DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS TZH:TZM') as created_at,
    TO_CHAR(TO_TIMESTAMP(started_at, 'YYYY/MM/DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS TZH:TZM') as started_at,
    case when state ilike 'backlog%' then 'Backlogged' when state ilike any ('DONE', 'Done') then 'Completed' else state end as state,
    team,
    priority,
    name,
    workflow,
    is_archived,
    is_blocked,
    is_completed,
    TO_CHAR(TO_TIMESTAMP(completed_at, 'YYYY/MM/DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS TZH:TZM') as completed_at,
    value as split_value,
    labels
from
    analytics.gs.engineering_shortcut_stories,
    LATERAL FLATTEN(INPUT => SPLIT(labels, ';'))
where
    contains(labels,'VIP')
    AND type = 'feature'
    AND is_archived = false  -- Exclude archived requests
    AND requester = 'integrations@equipmentshare.com'
    AND not state ilike any ('DONE', 'PICK%', 'Will %', 'Duplicate %', 'SaaSy')
    --AND (completed_at is null OR (completed_at is not null AND state in ('Long term vision'))) --dropping out will not be pursued
)
, splitting_labels_defects as (
select
    id,
    TO_CHAR(TO_TIMESTAMP(created_at, 'YYYY/MM/DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS TZH:TZM') as created_at,
    TO_CHAR(TO_TIMESTAMP(started_at, 'YYYY/MM/DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS TZH:TZM') as started_at,
    case when state ilike 'backlog%' then 'Backlogged' when state ilike any ('DONE', 'Done') then 'Completed' else state end as state,
    team,
    priority,
    name,
    workflow,
    is_archived,
    is_blocked,
    is_completed,
    TO_CHAR(TO_TIMESTAMP(completed_at, 'YYYY/MM/DD HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS TZH:TZM') as completed_at,
    value as split_value,
    labels
from
    analytics.gs.engineering_shortcut_stories,
    LATERAL FLATTEN(INPUT => SPLIT(labels, ';'))
where
    contains(labels,'VIP')
    AND type in ('chore','bug')
    AND is_archived = false  -- Exclude archived requests
    AND requester = 'integrations@equipmentshare.com'
    AND not state ilike any ('DONE', 'PICK%', 'Will %', 'Duplicate %', 'SaaSy')
    --AND (completed_at is null OR (completed_at is not null AND state in ('Long term vision'))) --dropping out will not be pursued
)
select
    'Feature Request' as card_type,
    id,
    trim(split_value,'"') as clean_label,
    TO_TIMESTAMP(created_at, 'YYYY-MM-DD HH24:MI:SS TZH:TZM') as created_at,
    TO_TIMESTAMP(started_at,'YYYY-MM-DD HH24:MI:SS TZH:TZM') as started_at,
    state,
    team,
    priority,
    name,
    workflow,
    is_blocked,
    is_completed,
    TO_TIMESTAMP(completed_at,'YYYY-MM-DD HH24:MI:SS TZH:TZM') as completed_at,
    case
    when split_value like '%Capital Equipment%' then 50
    when split_value like '%JE Dunn%' then 8935
    when split_value like '%Emery Sapp & Sons%' then 2968
    when split_value like '%City Rent A Truck%' then 7978
    when split_value like '%Superior Construction%' then 5437
    when split_value like '%Flintco%' then 5658
    when split_value like '%Granite Rock Company%' then 24008
    when split_value like '%Houston Heavy Machinery%' then 11674
    when split_value like '%AWR%' then 60574
    when split_value like '%Mountain F%' then 10924
    else 0
    end as company_id
from
    splitting_labels_feature_requets
where
    split_value like '%VIP%'
UNION
select
    'Defect' as card_type,
    id,
    trim(split_value,'"') as clean_label,
    TO_TIMESTAMP(created_at,'YYYY-MM-DD HH24:MI:SS TZH:TZM') as created_at,
    TO_TIMESTAMP(started_at,'YYYY-MM-DD HH24:MI:SS TZH:TZM') as started_at,
    state,
    team,
    priority,
    name,
    workflow,
    is_blocked,
    is_completed,
    TO_TIMESTAMP(completed_at,'YYYY-MM-DD HH24:MI:SS TZH:TZM') as completed_at,
    case
    when split_value like '%Capital Equipment%' then 50
    when split_value like '%JE Dunn%' then 8935
    when split_value like '%Emery Sapp & Sons%' then 2968
    when split_value like '%City Rent A Truck%' then 7978
    when split_value like '%Superior Construction%' then 5437
    when split_value like '%Flintco%' then 5658
    when split_value like '%Granite Rock Company%' then 24008
    when split_value like '%Houston Heavy Machinery%' then 11674
    when split_value like '%AWR%' then 60574
    when split_value like '%Mountain F%' then 10924
    else 0
    end as company_id
from
    splitting_labels_defects
where
    split_value like '%VIP%';;
  }

  # Dimensions
  dimension: id {
    type: string
    primary_key: yes
    sql: ${TABLE}.id ;;
    drill_fields: [details*]

  }

  dimension: card_type {
    type: string
    sql: ${TABLE}.card_type ;;
    drill_fields: [details*]
  }

  dimension: clean_label {
    type: string
    sql: ${TABLE}.clean_label ;;
    drill_fields: [details*]
  }

  dimension: state {
    type: string
    sql: ${TABLE}.state ;;
    drill_fields: [details*]
  }

  dimension: team {
    type: string
    sql: ${TABLE}.team ;;
    drill_fields: [details*]
  }

  dimension: priority_label {
    type: string
    sql: CASE
         WHEN ${TABLE}.priority IS NULL THEN 'Unknown'
         ELSE ${TABLE}.priority
       END ;;
    group_label: "Priority"
    description: "Priority label with 'Unknown' for null values."
  }

 # Helper Dimension
  dimension: priority_rank {
    type: number
    sql: CASE
         WHEN ${priority_label} = 'Highest' THEN 4
         WHEN ${priority_label} = 'High' THEN 3
         WHEN ${priority_label} = 'Medium' THEN 2
         WHEN ${priority_label} = 'Low' THEN 1
         ELSE 0
       END ;;
    group_label: "Priority"
    description: "Numerical rank for priority levels, with 'Unknown' as 0."
    drill_fields: [details*]
  }

  dimension: name {
    type: string
    sql: ${TABLE}.name ;;
    drill_fields: [details*]
  }

  dimension: workflow{
    type: string
    sql: ${TABLE}.workflow;;
  }

  dimension: is_completed{
    type: yesno
    sql: ${TABLE}.is_completed;;
    drill_fields: [details*]
  }

  dimension: company_id {
    type: string
    sql: ${TABLE}.company_id ;;
    drill_fields: [details*]
  }


  dimension_group: created_at {
    type: time
    sql: ${TABLE}.created_at;;
  }

  dimension_group: started_at {
    type: time
    sql: ${TABLE}.started_at ;;
  }

   dimension_group: completed_at {
    type: time
    sql: ${TABLE}.completed_at ;;
  }

  dimension: time_to_complete {
    type: number
    sql:  DATEDIFF(day, ${started_at_date}, ${completed_at_date});;
    drill_fields: [details*]
  }

  dimension: total_time {
    type: number
    sql: TRUNC((TIMEDIFF(hour, ${created_at_hour}, ${completed_at_hour}) / 24), 0);;
    drill_fields: [details*]
  }

  dimension: time_to_start {
    type: number
    sql:  DATEDIFF(day, ${created_at_date}, ${started_at_date});;
    drill_fields: [details*]
  }

  # Measures
  measure: total_feature_requests {
    type: count_distinct
    sql: ${id} ;;
    filters: [card_type: "Feature Request"]
    drill_fields: [details*]
    description: "Counts all unique feature requests."
  }

  measure: total_defects {
    type: count
    filters: [card_type: "Defect"]
    drill_fields: [details*]
  }

  measure: feature_requests_by_priority {
    type: count
    drill_fields: [details*]
  }

  measure: completed_feature_requests {
    type: count_distinct
    sql: ${id} ;;
    filters: [card_type: "Feature Request", is_completed: "Yes"]
    description: "Counts all unique completed feature requests."
  }

  measure: count_unique_cards {
    type: count_distinct
    sql: ${id} ;;
  }

  measure: count {
    type: count
    drill_fields: [details*]
  }

  drill_fields: [details*]

  set: details {
    fields: [
    id
    , clean_label
    , name
    , team
    , card_type
    , workflow
    , created_at_date
    , started_at_date
    , completed_at_date
    , time_to_complete
    , total_time
  ]
  }

  filter: completed {
    sql: ${is_completed} = 'Yes' ;;
  }
}
