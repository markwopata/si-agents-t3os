# The name of this view in Looker is "Company Tags"
view: company_tags {
  # The sql_table_name parameter indicates the underlying database table
  # to be used for all fields in this view.
  sql_table_name: "WORK_ORDERS"."COMPANY_TAGS"
    ;;
  drill_fields: [company_tag_id]
  # This primary key is the unique key for this table in the underlying database.
  # You need to define a primary key in a view in order to join to other views.

  dimension: company_tag_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."COMPANY_TAG_ID" ;;
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
  # This dimension will be called "Color" in Explore.

  dimension: color {
    type: string
    sql: ${TABLE}."COLOR" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  measure: tags_assigned_to_work_order {
    type: list
    list_field: name
  }

  measure: count {
    type: count
    drill_fields: [company_tag_id, name]
  }
}
