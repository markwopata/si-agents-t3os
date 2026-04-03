# The name of this view in Looker is "Credit App Master List"
view: credit_app_master_list {
  # The sql_table_name parameter indicates the underlying database table
  # to be used for all fields in this view.
  sql_table_name: "GS"."CREDIT_APP_MASTER_LIST"
    ;;
  # No primary key is defined for this view. In order to join this view in an Explore,
  # define primary_key: yes on a dimension that has no repeated values.

  # Here's what a typical dimension looks like in LookML.
  # A dimension is a groupable field that can be used to filter query results.
  # This dimension will be called " " in Explore.

  dimension: _ {
    type: string
    sql: ${TABLE}."_" ;;
  }

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

  dimension: app_status {
    type: string
    sql: ${TABLE}."APP_STATUS" ;;
  }

  dimension: credit_score {
    type: number
    sql: ${TABLE}."CREDIT_SCORE" ;;
  }

  dimension: credit_specialist {
    type: string
    sql: ${TABLE}."CREDIT_SPECIALIST" ;;
  }

  dimension: customer {
    type: string
    sql: ${TABLE}."CUSTOMER" ;;
  }

  dimension: customer_id {
    type: string
    sql: ${TABLE}."CUSTOMER_ID" ;;
  }

  dimension_group: date_completed {
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
    sql: CAST(${TABLE}."DATE_COMPLETED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: date_received {
    type: string
    sql: ${TABLE}."DATE_RECEIVED" ;;
  }

  dimension: duns_ {
    type: string
    sql: ${TABLE}."DUNS_" ;;
  }

  dimension: es_admin_setup {
    type: string
    sql: ${TABLE}."ES_ADMIN_SETUP" ;;
  }

  dimension: fein {
    type: string
    sql: ${TABLE}."FEIN" ;;
  }

  dimension: government_entity {
    type: string
    sql: ${TABLE}."GOVERNMENT_ENTITY" ;;
  }

  dimension: linked_to_intacct {
    type: string
    sql: ${TABLE}."LINKED_TO_INTACCT" ;;
  }

  dimension: market {
    type: string
    sql: ${TABLE}."MARKET" ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: naics_1 {
    type: string
    sql: ${TABLE}."NAICS_1" ;;
  }

  dimension: naics_2 {
    type: string
    sql: ${TABLE}."NAICS_2" ;;
  }

  dimension: notes {
    type: string
    sql: ${TABLE}."NOTES" ;;
  }

  dimension: ofac {
    type: string
    sql: ${TABLE}."OFAC" ;;
  }

  dimension: ra_required {
    type: string
    sql: ${TABLE}."RA_REQUIRED" ;;
  }

  dimension: sales_person {
    type: string
    sql: ${TABLE}."SALES_PERSON" ;;
  }

  dimension: salesperson_user_id {
    type: string
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  }

  dimension: sic {
    type: string
    sql: ${TABLE}."SIC" ;;
  }

  dimension: tin {
    type: string
    sql: ${TABLE}."TIN" ;;
  }

  dimension: welcome_letter {
    type: string
    sql: ${TABLE}."WELCOME_LETTER" ;;
  }

  dimension: x {
    type: string
    sql: ${TABLE}."X" ;;
  }

  dimension: xero_setup {
    type: string
    sql: ${TABLE}."XERO_SETUP" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
