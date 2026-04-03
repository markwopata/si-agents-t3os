view: maintenance_group_intervals {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."MAINTENANCE_GROUP_INTERVALS" ;;
  drill_fields: [maintenance_group_interval_id]

  dimension: maintenance_group_interval_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."MAINTENANCE_GROUP_INTERVAL_ID" ;;
  }
  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: date_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: date_updated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_UPDATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: delete {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DELETE_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }
  dimension: maintenance_group_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."MAINTENANCE_GROUP_ID" ;;
  }
  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }
  dimension: secondary_usage_trigger_from_due {
    type: number
    sql: ${TABLE}."SECONDARY_USAGE_TRIGGER_FROM_DUE" ;;
  }
  dimension: secondary_usage_warn_from_due {
    type: number
    sql: ${TABLE}."SECONDARY_USAGE_WARN_FROM_DUE" ;;
  }
  dimension: service_interval_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."SERVICE_INTERVAL_ID" ;;
  }
  dimension: trigger_from_due {
    type: number
    sql: ${TABLE}."TRIGGER_FROM_DUE" ;;
  }
  dimension: usage_trigger_from_due {
    type: number
    sql: ${TABLE}."USAGE_TRIGGER_FROM_DUE" ;;
  }
  dimension: usage_warn_from_due {
    type: number
    sql: ${TABLE}."USAGE_WARN_FROM_DUE" ;;
  }
  dimension: warn_from_due {
    type: number
    sql: ${TABLE}."WARN_FROM_DUE" ;;
  }
  measure: count {
    type: count
    drill_fields: [detail*]
  }
  measure: count_maintenane_group_intervals {
    type: count_distinct
    sql: ${maintenance_group_interval_id} ;;
    drill_fields: [companies.name,count_mgi_company]
  }
  measure: count_mgi_company {
    type: count_distinct
    sql: ${maintenance_group_interval_id} ;;
    drill_fields: [companies.name,name,service_intervals.interval_type]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
  maintenance_group_interval_id,
  name,
  service_intervals.name,
  service_intervals.service_interval_id,
  maintenance_groups.maintenance_group_id,
  maintenance_groups.name
  ]
  }

}

view: maintenance_group_interval_group{
  derived_table: {
    sql:
      select
          mgi.maintenance_group_id,
          iff(sum(iff(si.time_interval_id is not null and si.usage_interval_id is not null,1,0))>0,true,false) as combo
      from es_warehouse.public.maintenance_group_intervals mgi
      inner join es_warehouse.public.service_intervals si
          on mgi.service_interval_id = si.service_interval_id
      group by mgi.maintenance_group_id;;
  }
  dimension: maintenance_group_id {
    type: number
    sql: ${TABLE}."MAINTENANCE_GROUP_ID" ;;
    value_format: "0"
  }
  dimension: has_combo {
    type: yesno
    sql: ${TABLE}."COMBO";;
  }
}
