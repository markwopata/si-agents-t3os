# The name of this view in Looker is "Utilization Rankings"
view: utilization_rankings {
  # The sql_table_name parameter indicates the underlying database table
  # to be used for all fields in this view.
  sql_table_name: "PUBLIC"."UTILIZATION_RANKINGS"
    ;;
  drill_fields: [id]
  # This primary key is the unique key for this table in the underlying database.
  # You need to define a primary key in a view in order to join to other views.

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ID" ;;
  }

  # Dates and timestamps can be represented in Looker using a dimension group of type: time.
  # Looker converts dates and timestamps to the specified timeframes within the dimension group.

  dimension_group: date_recorded {
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
    sql: ${TABLE}."DATE_RECORDED" ;;
  }

  # Here's what a typical dimension looks like in LookML.
  # A dimension is a groupable field that can be used to filter query results.
  # This dimension will be called "Fin Util" in Explore.

  dimension: fin_util {
    type: number
    sql: ${TABLE}."FIN_UTIL" ;;
  }

  dimension: fin_util_rank {
    type: number
    sql: ${TABLE}."FIN_UTIL_RANK" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: oec_on_rent_perc {
    type: number
    sql: ${TABLE}."OEC_ON_RENT_PERC" ;;
  }

  dimension: oec_on_rent_perc_rank {
    type: number
    sql: ${TABLE}."OEC_ON_RENT_PERC_RANK" ;;
  }

  dimension: revenue_31_days {
    type: number
    sql: ${TABLE}."REVENUE_31_DAYS" ;;
  }

  # A measure is a field that uses a SQL aggregate function. Here are defined sum and average
  # measures for this dimension, but you can also add measures of many different aggregates.
  # Click on the type parameter to see all the options in the Quick Help panel on the right.

  measure: total_revenue_31_days {
    type: sum
    sql: ${revenue_31_days} ;;
  }

  measure: average_revenue_31_days {
    type: average
    sql: ${revenue_31_days} ;;
  }

  dimension: snowflake_task {
    type: string
    sql: ${TABLE}."SNOWFLAKE_TASK" ;;
  }

  dimension: total_assets {
    type: number
    sql: ${TABLE}."TOTAL_ASSETS" ;;
  }

  dimension: total_oec {
    type: number
    sql: ${TABLE}."TOTAL_OEC" ;;
  }

  dimension: total_oec_on_rent {
    type: number
    sql: ${TABLE}."TOTAL_OEC_ON_RENT" ;;
  }

  dimension: total_units_on_rent {
    type: number
    sql: ${TABLE}."TOTAL_UNITS_ON_RENT" ;;
  }

  dimension: unit_util {
    type: number
    sql: ${TABLE}."UNIT_UTIL" ;;
  }

  dimension: unit_util_rank {
    type: number
    sql: ${TABLE}."UNIT_UTIL_RANK" ;;
  }

  measure: count {
    type: count
    drill_fields: [id, market_name]
  }
}
