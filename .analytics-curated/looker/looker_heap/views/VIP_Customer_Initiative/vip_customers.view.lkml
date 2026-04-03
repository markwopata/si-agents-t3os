
view: vip_customers {
  derived_table: {
    sql: with splitting_labels as (
      select
          id,
          created_at,
          state,
          team,
          priority,
          value as split_value,
          labels
      from
          analytics.gs.engineering_shortcut_stories,
          LATERAL FLATTEN(INPUT => SPLIT(labels, ';'))
      where
          contains(labels,'VIP')
          AND type = 'feature'
          AND requester = 'integrations@equipmentshare.com'
          AND (completed_at is null OR (completed_at is not null AND state in ('Long term vision'))) --dropping out will not be pursued
      )
      select
          id,
          trim(split_value,'"') as clean_label,
          created_at,
          state,
          team,
          priority,
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
          splitting_labels
      where
          split_value like '%VIP%' ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: id {
    type: number
    primary_key: yes
    sql: ${TABLE}."ID" ;;
  }

  dimension: clean_label {
    type: string
    sql: ${TABLE}."CLEAN_LABEL" ;;
  }

  dimension: created_at {
    type: date
    sql: ${TABLE}."CREATED_AT" ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}."STATE" ;;
  }

  dimension: team {
    type: string
    sql: ${TABLE}."TEAM" ;;
  }

  dimension: priority {
    type: string
    sql: ${TABLE}."PRIORITY" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  set: detail {
    fields: [
        id,
  clean_label,
  created_at,
  state,
  team,
  priority,
  company_id
    ]
  }
}
