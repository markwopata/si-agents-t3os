# The name of this view in Looker is "Collectors Wos Columns"
view: collectors_wos_columns {
  # The sql_table_name parameter indicates the underlying database table
  # to be used for all fields in this view.
  sql_table_name: "GOOGLE_SHEETS"."COLLECTORS_WOS_COLUMNS"
    ;;
  # No primary key is defined for this view. In order to join this view in an Explore,
  # define primary_key: yes on a dimension that has no repeated values.

  # Dates and timestamps can be represented in Looker using a dimension group of type: time.
  # Looker converts dates and timestamps to the specified timeframes within the dimension group.

  dimension_group: _fivetran_synced {
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
    sql: CAST(${TABLE}."_FIVETRAN_SYNCED" AS TIMESTAMP_NTZ) ;;
  }

  # Here's what a typical dimension looks like in LookML.
  # A dimension is a groupable field that can be used to filter query results.
  # This dimension will be called " Row" in Explore.

  dimension: _row {
    type: number
    sql: ${TABLE}."_ROW" ;;
  }

  # A measure is a field that uses a SQL aggregate function. Here are defined sum and average
  # measures for this dimension, but you can also add measures of many different aggregates.
  # Click on the type parameter to see all the options in the Quick Help panel on the right.

  measure: total__row {
    type: sum
    sql: ${_row} ;;
  }

  measure: average__row {
    type: average
    sql: ${_row} ;;
  }

  dimension: customer_id {
    type: number
    sql: ${TABLE}."CUSTOMER_ID" ;;
    value_format_name: id
  }

  dimension: gl_1227 {
    type: string
    sql: ${TABLE}."GL_1227" ;;
  }

  dimension: owed_09132021 {
    type: number
    sql: ${TABLE}."OWED_09132021" ;;
    value_format_name: usd
  }

  dimension: paid {
    type: number
    sql: ${TABLE}."PAID" ;;
    value_format_name: usd
  }

  dimension: state {
    type: string
    sql: ${TABLE}."STATE" ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }

  dimension: total_outstanding {
    type: number
    sql: ${TABLE}."TOTAL_OUTSTANDING" ;;
    value_format_name: usd

  }

  dimension: write_off {
    type: number
    sql: ${TABLE}."WRITE_OFF" ;;
    value_format_name: usd
  }

  measure: count {
    type: count
    drill_fields: []
  }
  dimension: 3rd_Party_Assigned {
    type: string
    sql: ${TABLE}."_3_RD_PARTY_ASSIGNED" ;;
  }
}
