
include: "/_standard/people_analytics/looker/labor_allocations.layer.lkml"
include: "/_standard/analytics/payroll/pa_market_access.layer.lkml"


view: labor_allocations_max{
  derived_table: {
    sql:
      SELECT
        MAX(snapshot_timestamp) AS SNAPSHOT_TIMESTAMP
        FROM PEOPLE_ANALYTICS.LOOKER.LABOR_ALLOCATIONS;;
  }
  dimension_group: max_date{
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}."SNAPSHOT_TIMESTAMP" ;;
  }
  dimension: join_date {
    type:  number
    sql: 1;;
  }
}

view: +labor_allocations{

    dimension: join_date {
    type:  number
    sql: 1;;
  }
}
explore: labor_allocations {


  sql_always_where:
  (CASE WHEN {% parameter timeframe_picker %} > ${labor_allocations_max.max_date_date}
  THEN ${snapshot_timestamp_date}=${labor_allocations_max.max_date_date}
  ELSE ${snapshot_timestamp_raw}  <= {% parameter timeframe_picker %} END)
  AND (
  'yes' = {{ _user_attributes['people_analytics_access'] }}
  OR CONTAINS(LOWER(${pa_market_access.market_access_email}),  LOWER('{{ _user_attributes['email'] }}'))
  );;

  join: pa_market_access {
    type: inner
    relationship: many_to_many
    sql_on: ${pa_market_access.market_id}::varchar = ${labor_allocations.market_id_allocation}::varchar;;
  }

  join: labor_allocations_max {
    type: left_outer
    relationship: one_to_many
    sql_on: ${labor_allocations.join_date}=${labor_allocations_max.join_date};;
  }

}
