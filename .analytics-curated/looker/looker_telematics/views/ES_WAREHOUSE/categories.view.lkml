# The name of this view in Looker is "Categories"
view: categories {
  # The sql_table_name parameter indicates the underlying database table
  # to be used for all fields in this view.
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."CATEGORIES"
    ;;
  drill_fields: [parent_category_id]
  # This primary key is the unique key for this table in the underlying database.
  # You need to define a primary key in a view in order to join to other views.

  dimension: parent_category_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."PARENT_CATEGORY_ID" ;;
  }

  # Dates and timestamps can be represented in Looker using a dimension group of type: time.
  # Looker converts dates and timestamps to the specified timeframes within the dimension group.

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

  # Here's what a typical dimension looks like in LookML.
  # A dimension is a groupable field that can be used to filter query results.
  # This dimension will be called "Active" in Explore.

  dimension: active {
    type: yesno
    sql: ${TABLE}."ACTIVE" ;;
  }

  dimension: canonical_name {
    type: string
    sql: ${TABLE}."CANONICAL_NAME" ;;
  }

  dimension: category_id {
    type: number
    sql: ${TABLE}."CATEGORY_ID" ;;
  }

  dimension: company_division_id {
    type: number
    sql: ${TABLE}."COMPANY_DIVISION_ID" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension_group: date_deactivated {
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
    sql: CAST(${TABLE}."DATE_DEACTIVATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: image {
    type: string
    sql: ${TABLE}."IMAGE" ;;
  }

  dimension: layout_script {
    type: string
    sql: ${TABLE}."LAYOUT_SCRIPT" ;;
  }

  dimension: name {
    type: string
    label: "Category"
    sql: ${TABLE}."NAME" ;;
  }

  dimension: singular_name {
    type: string
    sql: ${TABLE}."SINGULAR_NAME" ;;
  }

  dimension: sort_index {
    type: number
    sql: ${TABLE}."SORT_INDEX" ;;
  }

  # A measure is a field that uses a SQL aggregate function. Here are defined sum and average
  # measures for this dimension, but you can also add measures of many different aggregates.
  # Click on the type parameter to see all the options in the Quick Help panel on the right.

  measure: total_sort_index {
    type: sum
    sql: ${sort_index} ;;
  }

  measure: average_sort_index {
    type: average
    sql: ${sort_index} ;;
  }

  measure: count {
    type: count
    drill_fields: [parent_category_id, singular_name, name, canonical_name]
  }
}
