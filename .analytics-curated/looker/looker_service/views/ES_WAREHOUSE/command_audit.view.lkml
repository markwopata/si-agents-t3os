view: command_audit {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."COMMAND_AUDIT"
    ;;
  drill_fields: [command_audit_id]

  dimension: command_audit_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."COMMAND_AUDIT_ID" ;;
  }

  dimension_group: _es_update_timestamp {
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
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension: audit_event_source_id {
    type: number
    sql: ${TABLE}."AUDIT_EVENT_SOURCE_ID" ;;
  }
  dimension: command {
    type: string
    sql: ${TABLE}."COMMAND" ;;
  }
  dimension_group: date_created {
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
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension: parameters {
    type: string
    sql: ${TABLE}."PARAMETERS" ;;
  }

  dimension: work_order_id {
    type: string
    sql: ${TABLE}."PARAMETERS":work_order_id ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: work_order_audit {
    type: yesno
    sql: ${command} like '%Work%' ;;
  }

  measure: count {
    type: count
    drill_fields: [command_audit_id]
  }
}

view: last_interaction_date {
  derived_table: {
    sql:
with ca as (
      select ca.PARAMETERS:work_order_id work_order_id
        , max(ca.date_created) as last_interaction
      from ${command_audit.SQL_TABLE_NAME}ca
      join es_warehouse.work_orders.work_orders wo
        on wo.work_order_id = ca.PARAMETERS:work_order_id
      group by 1
)

select ca.work_order_id
    -- , ca.last_interaction
    -- , max_part
    -- , max_labor
    , case
        when ca.last_interaction >= coalesce(max_part, '1970-01-01') and ca.last_interaction >= coalesce(max_labor, '1970-01-01') then ca.last_interaction::DATE
        when coalesce(max_part, '1970-01-01') >= ca.last_interaction and coalesce(max_part, '1970-01-01') >= coalesce(max_labor, '1970-01-01') then max_part::DATE
        else max_labor::DATE end as last_interaction
from ca
left join (
        select pit.work_order_id
            , max(pit.date_completed) as max_part
        from ANALYTICS.INTACCT_MODELS.PART_INVENTORY_TRANSACTIONS pit
        where pit.work_order_id is not null
            and pit.date_cancelled is not null
        group by 1
        ) pit
    on pit.work_order_id = ca.work_order_id
left join (
        select te.work_order_id
            , max(te.start_date) as max_labor
        from ES_WAREHOUSE.TIME_TRACKING.TIME_ENTRIES te
        where te.work_order_id is not null
            and te.archived_date is null
            and te.event_type_id = 1
        group by 1
        ) te
    on te.work_order_id = ca.work_order_id;;
  }

  dimension: work_order_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.work_order_id ;;
  }

  dimension: last_interaction {
    type: date
    sql: ${TABLE}.last_interaction ;;
  }
}
